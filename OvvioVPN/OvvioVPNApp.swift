//
//  OvvioVPNApp.swift
//  OvvioVPN
//

import SwiftUI

@main
struct OvvioVPNApp: App {
    // 1. Read the consent status
    @AppStorage("hasAcceptedConsentOvvio") private var hasAcceptedConsent = false
    
    // 2. Lifecycle Monitor
    @Environment(\.scenePhase) var scenePhase
    
    // 3. Global State Managers
    @StateObject private var appStateManager = AppStateManager()
    @StateObject private var sideMenuManager = SideMenuManager()
    @StateObject private var accountViewModel = AccountViewModel()
    @StateObject private var homeViewModel = MainViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if !hasAcceptedConsent {
                    // Consent Screen (No VPN logic needed here)
                    UserConsentView()
                } else {
                    // Splash Screen -> Home View
                    Splash()
                        .environmentObject(appStateManager)
                        .environmentObject(sideMenuManager)
                        .environmentObject(accountViewModel)
                        .environmentObject(homeViewModel) // Pass the shared VM
                }
            }
            .preferredColorScheme(.light)
            
            // 4. THE AUTO-CONNECT TRIGGER
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    print("📱 App is Active. Checking Auto-Connect...")
                    
                    // This is safe because MainViewModel has the "Run Once" flag.
                    homeViewModel.checkAutoConnect()
                }
            }
        }
    }
}
