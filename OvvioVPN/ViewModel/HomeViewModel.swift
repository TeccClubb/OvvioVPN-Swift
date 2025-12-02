//
//  MainViewModel.swift
//  OvvioVPN
//

import SwiftUI
import Combine
import NetworkExtension
import Alamofire

// MARK: - API Response Models
struct RegisterClientData: Codable {
    let message: String
    let name: String
    let success: Bool
}

struct RegisterClientResponse: Codable {
    let connected: Bool
    let message: String
    let data: RegisterClientData?
}

class MainViewModel: ObservableObject {

    // MARK: - Published State
    @Published var connectionState: VPNConnectionState = .disconnected
    @Published var connectionTime: TimeInterval = 0
    @Published var selectedServerInfo: ConnectedServerInfo? = nil
    @Published var showServerList = false
    @Published var shouldShowPremium = false
    @Published var alertDetails: CustomAlertDetails? = nil

    // --- Properties ---
    private var appStateManager: AppStateManager?
    private var cancellables = Set<AnyCancellable>()
    private let vpnManager = VPNManager.shared
    
    private var timerSubscription: Cancellable?
    private var connectionStartTime: Date?
    
    // --- "Run Once" Flag ---
    private var hasPerformedLaunchCheck = false

    // --- UserDefaults Keys ---
    private let selectedServerKey = "user_selected_server_id"
    private let selectedServerIPKey = "user_selected_server_ip"
    private let selectedServerDomainKey = "user_selected_server_domain"
    private let selectedServerNameKey = "user_selected_server_name"
    private let selectedServerImageKey = "user_selected_server_image"
    private let selectedServerSubIDKey = "user_selected_server_sub_id"
    private let selectedServerTypeKey = "user_selected_server_type"

    @AppStorage("autoConnectEnabled") var autoConnectEnabled = false
    @AppStorage("killSwitchEnabled") var killSwitchEnabled = false
    
    // --- Computed Properties ---
    var isConnected: Bool {
        connectionState == .connected
    }

    var formattedTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: connectionTime) ?? "00 : 00 : 00"
    }

    // MARK: - Initialization
    init() {
        setupVPNStatusObserver()
    }
    
    func setAppStateManager(_ manager: AppStateManager) {
        self.appStateManager = manager
    }
    
    
    
    // MARK: - App Launch / Lifecycle Check
    func checkAutoConnect() {
        // Force VPNManager to reload system status
        vpnManager.loadPreferences() // <- this updates vpnStatus and posts notification
        
        // Immediately update UI
        updateConnectionStatus()
        
        if hasPerformedLaunchCheck { return }
        hasPerformedLaunchCheck = true
        
        // Delay for auto-connect logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.performLaunchLogic()
        }
    }


    
    private func performLaunchLogic() {
        let currentStatus = vpnManager.vpnStatus
        print("🔍 Launch Check: System status is \(vpnManager.getStatusString())")

        // 3. UI SYNC: If VPN is active, update UI immediately
        if currentStatus == .connected || currentStatus == .connecting {
            print("✅ VPN already active. Syncing UI...")
            self.updateConnectionStatus() // This sets isConnected = true and starts timer
            return
        }
        
        // 4. Auto-Connect Logic (Only runs if currently disconnected)
        if autoConnectEnabled {
            if vpnManager.userDisconnectedManually {
                print("🚫 Auto-Connect skipped (User disconnected manually)")
                return
            }
            print("🚀 Auto-Connect Triggered")
            connect()
        }
    }

    func toggleConnection() {
        if connectionState == .connected || connectionState == .connecting {
            disconnect()
        } else {
            connect()
        }
    }

    // MARK: - VPN Connection Logic
    func connect() {
        // 1. Validation
        guard let domain = UserDefaults.standard.string(forKey: selectedServerDomainKey),
              !domain.isEmpty,
              let serverIP = UserDefaults.standard.string(forKey: selectedServerIPKey),
              !serverIP.isEmpty else {
            self.showServerList = true
            return
        }
        
        let serverType = UserDefaults.standard.string(forKey: selectedServerTypeKey) ?? "free"
        let isPremiumUser = appStateManager?.isPremium ?? false
        
        if serverType == "premium" && !isPremiumUser {
            self.shouldShowPremium = true
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let name = UserDefaults.standard.string(forKey: "userName") else {
            return
        }
        
        let username = "\(name)_ios"
        let passwordString = "Test@12345" // Correct Password

        print("Connecting... Step 1: Registering Client")
        self.connectionState = .connecting
        
        // 2. API Call
        APIManager.shared.request(
            .registerClient(ip: serverIP, client_name: username, password: passwordString, token: token)
        ) { [weak self] (result: Result<RegisterClientResponse, AFError>, _) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.connected {
                        print("✅ API Success. Step 2: Starting VPN Tunnel")
                        let serverName = UserDefaults.standard.string(forKey: self.selectedServerNameKey) ?? "OvvioVPN"
                        
                        self.triggerVPNManager(
                            domain: domain,
                            username: username,
                            password: passwordString,
                            serverName: serverName
                        )
                    } else {
                        print("❌ API Registration Failed: \(response.message)")
                        self.handleError(response.message)
                    }
                case .failure(let error):
                    print("❌ API Error: \(error.localizedDescription)")
                    self.handleError(error.localizedDescription)
                }
            }
        }
    }
    
    private func triggerVPNManager(domain: String, username: String, password: String, serverName: String) {
        vpnManager.connect(
            vpnType: "IKEv2",
            vpnServer: domain,
            vpnUsername: username,
            vpnPassword: password,
            vpnDescription: "OvvioVPN - \(serverName)",
            isKillSwitchEnabled: self.killSwitchEnabled
        )
    }
    
    private func handleError(_ message: String) {
        self.connectionState = .disconnected
        self.alertDetails = CustomAlertDetails(type: .error, title: "Connection Failed", message: message)
    }

    func disconnect() {
        print("🔌 Disconnecting...")
        vpnManager.disconnect(userInitiated: true)
        stopTimer()
           connectionTime = 0
           connectionStartTime = nil
           
           // Optional: Remove saved start time from UserDefaults
           UserDefaults.standard.removeObject(forKey: "vpn_connection_start_time")
    }

    // MARK: - Status Observer
    private func setupVPNStatusObserver() {
        NotificationCenter.default.publisher(for: Notification.Name("VPNStatusChanged"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateConnectionStatus() }
            .store(in: &cancellables)
    }

    private func updateConnectionStatus() {
        let status = vpnManager.vpnStatus
        print("VPN Status Update: \(vpnManager.getStatusString())")
        
        switch status {
        case .connected:
            self.connectionState = .connected
            startTimer()
            loadServerInfoForUI()
        case .connecting, .reasserting:
            self.connectionState = .connecting
        case .disconnecting:
            self.connectionState = .disconnecting
        case .disconnected, .invalid:
            self.connectionState = .disconnected
            stopTimer()
            connectionTime = 0
            connectionStartTime = nil
            self.selectedServerInfo = nil
            UserDefaults.standard.removeObject(forKey: "vpn_connection_start_time")
        @unknown default:
            self.connectionState = .disconnected
        }
    }

    private func loadServerInfoForUI() {
        let serverName = UserDefaults.standard.string(forKey: selectedServerNameKey) ?? "Selected Server"
        let serverImageURL = UserDefaults.standard.string(forKey: selectedServerImageKey) ?? ""
        let serverIP = UserDefaults.standard.string(forKey: selectedServerIPKey) ?? "---"
        
        self.selectedServerInfo = ConnectedServerInfo(
            flagImageName: serverImageURL,
            country: serverName,
            cityAndIP: serverIP,
            pingMillis: 0
        )
    }

    func selectAutoServer() { print("Auto Select Tapped") }
    func openSideMenu() { print("Open Side Menu") }
    func openPremiumView() { shouldShowPremium = true }

    // MARK: - Timer Logic
    private func startTimer() {
        stopTimer()
        
        // Attempt to restore start time from disk
        if let savedStart = UserDefaults.standard.object(forKey: "vpn_connection_start_time") as? Date {
            connectionStartTime = savedStart
        } else {
            // Only set new time if none exists
            let now = Date()
            connectionStartTime = now
            UserDefaults.standard.set(now, forKey: "vpn_connection_start_time")
        }
        
        if let startTime = connectionStartTime {
            connectionTime = Date().timeIntervalSince(startTime)
        }
        
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self, self.connectionState == .connected, let start = self.connectionStartTime else {
                self?.stopTimer()
                return
            }
            self.connectionTime = Date().timeIntervalSince(start)
        }
    }

    
    func disconnectAndWait() async {
        disconnect()

        // Wait until state actually becomes disconnected
        while connectionState != .disconnected {
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 sec
        }

        // Reset timer for safety
        stopTimer()
        connectionTime = 0
        connectionStartTime = nil
    }

    
    private func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
        // Important: We only nullify the variable, we don't wipe UserDefaults
        // so if the app crashes and reopens, 'startTimer' can recover the original time.
    }

    deinit {
        stopTimer()
        cancellables.forEach { $0.cancel() }
    }
}
