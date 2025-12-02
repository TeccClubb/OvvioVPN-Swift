import Foundation
import Alamofire
import SwiftyPing

struct DisplayableServer: Identifiable {
    let id: Int
    let country: WelcomeServer
    let subServer: SubServer
    
    var vpsServer: VpsGroupServer? {
        subServer.vpsGroup.servers.first
    }
}

class ServerListViewModel: ObservableObject {
    
    @Published var searchText = ""
    @Published var quickSelection: QuickAction? = nil
    @Published var selectedTab: ServerTab = .allServers
    
    @Published private var displayableServers: [DisplayableServer] = []
    
    @Published var favouriteServerIDs: Set<Int> = []
    @Published var pingResults: [Int: Double] = [:]
    
    @Published var selectedServerID: Int?
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var showPremiumPopup = false
    
    private var appStateManager: AppStateManager?
    private var activePingers: [Int: SwiftyPing] = [:]
    private var pingTimer: Timer?
    
    private let favouritesKey = "user_favourite_servers"
    private let selectedServerKey = "user_selected_subserver_id"
    
    init() {
        fetchRealServers()
        loadFavourites()
        
        let saved = UserDefaults.standard.integer(forKey: selectedServerKey)
        if saved != 0 { selectedServerID = saved }
    }
    
    func setAppStateManager(_ manager: AppStateManager) {
        self.appStateManager = manager
    }
    
    // MARK: - Filter logic
    var filteredServers: [DisplayableServer] {
        let baseList: [DisplayableServer]
        
        switch selectedTab {
        case .allServers:
            baseList = displayableServers
        case .premium:
            baseList = displayableServers.filter { $0.country.type == .premium }
        case .favourites:
            baseList = displayableServers.filter { favouriteServerIDs.contains($0.id) }
        }
        
        if searchText.isEmpty { return baseList }
        
        let search = searchText.lowercased()
        return baseList.filter {
            $0.country.name.lowercased().contains(search) ||
            $0.subServer.name.lowercased().contains(search)
        }
    }
    
    // MARK: - Quick Action Handlers
    func handleFastestServerTap(onSuccess: @escaping () -> Void) {
        quickSelection = .fastest
        
        if let fastest = serverWithLowestPing() {
            let ok = selectServer(fastest)
            if ok { onSuccess() }
        }
    }
    
    func handleRandomServerTap(onSuccess: @escaping () -> Void) {
        quickSelection = .random
        
        if let random = randomServer() {
            let ok = selectServer(random)
            if ok { onSuccess() }
        }
    }
    
    // MARK: - Server Selection
    func selectServer(_ server: DisplayableServer) -> Bool {
        let isPremium = appStateManager?.isPremium ?? false
        
        if server.country.type == .premium && !isPremium {
            showPremiumPopup = true
            return false
        }
        
        guard let vps = server.vpsServer else { return false }
        
        selectedServerID = server.id
        
        // SAVE ALL REQUIRED VALUES
        UserDefaults.standard.set(server.id, forKey: selectedServerKey)
        UserDefaults.standard.set(vps.ipAddress, forKey: "user_selected_server_ip")
        UserDefaults.standard.set(vps.domain, forKey: "user_selected_server_domain")
        UserDefaults.standard.set(server.country.image, forKey: "user_selected_server_image")
        UserDefaults.standard.set("\(server.country.name) - \(server.subServer.name)", forKey: "user_selected_server_name")

        // 🔥🔥 REQUIRED FIELDS (FIX)
        UserDefaults.standard.set(server.subServer.id, forKey: "user_selected_server_sub_id")
        UserDefaults.standard.set(server.country.type.rawValue, forKey: "user_selected_server_type")

        UserDefaults.standard.synchronize()

        print("""
            📡 Selected Server:
              • ID: \(server.id)
              • Country: \(server.country.name)
              • City: \(server.subServer.name)
              • Premium: \(server.country.type == .premium ? "Yes" : "No")
              • IP: \(vps.ipAddress)
              • Domain: \(vps.domain)
              • SubID: \(server.subServer.id)
              • Type: \(server.country.type.rawValue)
            """)
        
        return true
    }

    
    
    
    func toggleFavourite(for server: DisplayableServer) {
        if favouriteServerIDs.contains(server.id) {
            favouriteServerIDs.remove(server.id)
        } else {
            favouriteServerIDs.insert(server.id)
        }
        
        saveFavourites()
    }
    
    // MARK: - Networking
    func fetchRealServers() {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else { return }
        isLoading = true
        
        APIManager.shared.request(.getServer(platform: "ios", token: token)) { [weak self] (result: Result<ServerResponse, AFError>, _) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let res):
                    if res.status {
                        var flat: [DisplayableServer] = []
                        for country in res.servers {
                            for city in country.subServers {
                                flat.append(DisplayableServer(id: city.id, country: country, subServer: city))
                            }
                        }
                        self.displayableServers = flat
                        self.startPingTimer()
                    } else {
                        self.errorMessage = "Unable to load servers."
                    }
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Ping Logic (5s interval)
    private func startPingTimer() {
        pingTimer?.invalidate()
        pingTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.performPing()
        }
        pingTimer?.fire() // optional immediate ping
    }
    
    private func performPing() {
        for server in displayableServers {
            guard let ip = server.vpsServer?.ipAddress else {
                pingResults[server.id] = -1
                continue
            }

            // Mark as loading state
            pingResults[server.id] = -2

            // If already pinging — skip
            if activePingers[server.id] != nil { continue }

            do {
                let config = PingConfiguration(interval: 5, with: 1)
                let pinger = try SwiftyPing(host: ip, configuration: config, queue: .global())

                activePingers[server.id] = pinger

                var hasResponded = false

                pinger.observer = { [weak self] response in
                    DispatchQueue.main.async {
                        guard let self = self else { return }

                        hasResponded = true

                        if response.error != nil {
                            self.pingResults[server.id] = -1
                        } else {
                            self.pingResults[server.id] = response.duration * 1000
                        }

                        // Stop pinger after first response
                        self.activePingers[server.id]?.stopPinging()
                        self.activePingers[server.id] = nil
                    }
                }

                try pinger.startPinging()

                // Safety timeout: stop after 2 seconds if no reply
                DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
                    guard let self = self else { return }
                    if !hasResponded {
                        DispatchQueue.main.async {
                            self.pingResults[server.id] = -1
                            self.activePingers[server.id]?.stopPinging()
                            self.activePingers[server.id] = nil
                        }
                    }
                }

            } catch {
                pingResults[server.id] = -1
            }
        }
    }


    
    // MARK: - Helpers
    private func saveFavourites() {
        UserDefaults.standard.set(Array(favouriteServerIDs), forKey: favouritesKey)
    }
    
    private func loadFavourites() {
        let ids = UserDefaults.standard.array(forKey: favouritesKey) as? [Int] ?? []
        favouriteServerIDs = Set(ids)
    }
    
    deinit {
        pingTimer?.invalidate()
        activePingers.values.forEach { $0.stopPinging() }
    }
}

// MARK: - Server Selection Helpers
extension ServerListViewModel {
    func serverWithLowestPing() -> DisplayableServer? {
        let isPremiumUser = appStateManager?.isPremium ?? false
        let allowedServers = displayableServers.filter { $0.country.type == .premium ? isPremiumUser : true }
        
        let serversWithPing = allowedServers.compactMap { server -> (DisplayableServer, Double)? in
            guard let ping = pingResults[server.subServer.id], ping >= 0 else { return nil }
            return (server, ping)
        }
        
        let sorted = serversWithPing.sorted { $0.1 < $1.1 }
        return sorted.first?.0
    }
    
    func randomServer() -> DisplayableServer? {
        let isPremium = appStateManager?.isPremium ?? false
        return displayableServers.filter { $0.country.type == .premium ? isPremium : true }
            .randomElement()
    }
}
