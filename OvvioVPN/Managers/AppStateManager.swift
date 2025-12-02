import SwiftUI
import Combine
import NetworkExtension

/// Manages global app state: authentication, premium, and VPN
class AppStateManager: ObservableObject {

    // MARK: - Persisted State
    @AppStorage("isUserAuthenticatedOvvio") private var isUserAuthenticated: Bool = false
    @AppStorage("isUserPremiumOvvio") private var isUserPremium: Bool = false

    // MARK: - Published State
    @Published var isAuthenticated: Bool
    @Published var isPremium: Bool

    // MARK: - Initializer
    init() {
        let storedAuth = UserDefaults.standard.bool(forKey: "isUserAuthenticatedOvvio")
        self._isUserAuthenticated = AppStorage(wrappedValue: storedAuth, "isUserAuthenticatedOvvio")
        self.isAuthenticated = storedAuth

        let storedPremium = UserDefaults.standard.bool(forKey: "isUserPremiumOvvio")
        self._isUserPremium = AppStorage(wrappedValue: storedPremium, "isUserPremiumOvvio")
        self.isPremium = storedPremium

        print("AppStateManager initialized → Authenticated: \(storedAuth), Premium: \(storedPremium)")
    }

    // MARK: - Public Methods
    func login() {
        isUserAuthenticated = true
        withAnimation { isAuthenticated = true }
        print("✅ AppStateManager: User logged in")
    }

    func logout() {
        // 1️⃣ Stop VPN if running
        stopVPN()

        // 2️⃣ Clear all UserDefaults
        clearAllUserDefaults()

        // 3️⃣ Update published properties
        withAnimation {
            isAuthenticated = false
            isPremium = false
        }

        print("🚪 AppStateManager: User logged out, VPN stopped, all UserDefaults cleared")
    }

    func updatePremiumStatus(to isPremium: Bool) {
        isUserPremium = isPremium
        withAnimation { self.isPremium = isPremium }
        print("💎 AppStateManager: Premium status updated to: \(isPremium)")
    }

    // MARK: - VPN Control
    private func stopVPN() {
        NEVPNManager.shared().connection.stopVPNTunnel()
        print("🛑 VPN stopped")
    }

    // MARK: - Clear All UserDefaults
    private func clearAllUserDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
            print("🧹 All UserDefaults cleared for bundle: \(bundleID)")
        }
    }
}
