//
//  VPNManager.swift
//  OvvioVPN
//

import Foundation
import NetworkExtension
import Security

class VPNManager {
    
    static let shared = VPNManager()
    
    private(set) var userDisconnectedManually = false
    private let keychain = KeychainService()

    private init() {
        print("✅ VPNManager Initialized")
        loadPreferences()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(statusChanged),
            name: .NEVPNStatusDidChange,
            object: nil
        )
    }

    var vpnManager: NEVPNManager { NEVPNManager.shared() }
    var vpnStatus: NEVPNStatus { vpnManager.connection.status }

    
     func loadPreferences() {
        vpnManager.loadFromPreferences { error in
            if let error = error {
                print("❌ Error loading VPN preferences: \(error.localizedDescription)")
            } else {
                print("✅ VPN preferences loaded")
                NotificationCenter.default.post(name: Notification.Name("VPNStatusChanged"), object: nil)
            }
        }
    }

    func connect(
        vpnType: String,
        vpnServer: String,
        vpnUsername: String,
        vpnPassword: String,
        vpnDescription: String?,
        isKillSwitchEnabled: Bool
    ) {
        self.userDisconnectedManually = false
        
        vpnManager.loadFromPreferences { [weak self] error in
            guard let self = self else { return }
            guard error == nil else {
                print("❌ VPN Preferences error: \(error!.localizedDescription)")
                return
            }
            
            // 1. Race Condition Guard
            if self.vpnStatus == .connected || self.vpnStatus == .connecting {
                print("⚠️ VPN is already \(self.getStatusString()). Aborting.")
                return
            }

            // 2. Save Password to Keychain
            let passwordKey = "vpn_password"
            self.keychain.saveItem(k: passwordKey, v: vpnPassword)
            
            guard let passwordRef = self.keychain.getPasswordReference(for: passwordKey) else {
                print("❌ Keychain Error: Could not get reference.")
                return
            }

            // 3. Configure Protocol
            let ikev2Protocol = NEVPNProtocolIKEv2()
            ikev2Protocol.username = vpnUsername
            ikev2Protocol.passwordReference = passwordRef
            ikev2Protocol.serverAddress = vpnServer
            ikev2Protocol.remoteIdentifier = vpnServer
            ikev2Protocol.authenticationMethod = .none
            ikev2Protocol.useExtendedAuthentication = true
            ikev2Protocol.disconnectOnSleep = false
            ikev2Protocol.deadPeerDetectionRate = .medium

            self.vpnManager.protocolConfiguration = ikev2Protocol
            self.vpnManager.localizedDescription = vpnDescription ?? "Ovvio VPN"
            self.vpnManager.isEnabled = true

            // 4. Kill Switch Setup
            if isKillSwitchEnabled {
                let connectRule = NEOnDemandRuleConnect()
                connectRule.interfaceTypeMatch = .any
                self.vpnManager.onDemandRules = [connectRule]
                self.vpnManager.isOnDemandEnabled = false // Important: AtomicSec style
                self.vpnManager.protocolConfiguration?.excludeLocalNetworks = false
                self.vpnManager.protocolConfiguration?.includeAllNetworks = true
            } else {
                self.vpnManager.onDemandRules = nil
                self.vpnManager.isOnDemandEnabled = false
            }

            // 5. Save & Start (Standard Robust Flow)
            self.vpnManager.saveToPreferences { error in
                if let error = error {
                    print("❌ Save Error: \(error.localizedDescription)")
                    return
                }
                
                // Double-Load to sync with OS state
                self.vpnManager.loadFromPreferences { error in
                    if let error = error {
                        print("❌ Reload Error: \(error.localizedDescription)")
                        return
                    }
                    
                    do {
                        try self.vpnManager.connection.startVPNTunnel()
                        print("🚀 VPN Tunnel Start Requested")
                    } catch {
                        print("❌ Start Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func disconnect(userInitiated: Bool = true) {
        self.userDisconnectedManually = userInitiated
        vpnManager.connection.stopVPNTunnel()
        print("🔌 VPN Stopped")
    }

    func getStatusString() -> String {
        switch vpnStatus {
        case .connected: return "Connected"
        case .connecting: return "Connecting"
        case .disconnected: return "Disconnected"
        case .disconnecting: return "Disconnecting"
        case .invalid: return "Invalid"
        case .reasserting: return "Reasserting"
        @unknown default: return "Unknown"
        }
    }

    @objc private func statusChanged() {
        NotificationCenter.default.post(name: Notification.Name("VPNStatusChanged"), object: nil)
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
}
