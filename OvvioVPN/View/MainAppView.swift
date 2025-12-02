// MainAppView.swift
import SwiftUI

struct MainAppView: View {
    @EnvironmentObject var sideMenuManager: SideMenuManager
    @EnvironmentObject var appStateManager: AppStateManager
    
    // --- 1. THIS IS THE FIX ---
    // We *receive* the view model, we don't *create* it
    @EnvironmentObject var accountViewModel: AccountViewModel
    // --- (The @StateObject line is GONE) ---

    private var menuWidth: CGFloat {
        UIScreen.main.bounds.width * 0.75 // 75% of screen width
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .leading) {
                
                // --- 2. NO CHANGE NEEDED ---
                // .environmentObject() is no longer needed here,
                // because 'SideMenu' will get it from 'MainAppView's environment.
                SideMenu()
                    .frame(width: menuWidth)
                    .offset(x: sideMenuManager.isSideMenuOpen ? 0 : -menuWidth)
                    .zIndex(2)

                // --- 3. NO CHANGE NEEDED ---
                // 'HomeView' will also get it from the environment.
                HomeView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .disabled(sideMenuManager.isSideMenuOpen)
                    .zIndex(0)

                // --- Tap-to-Close Overlay ---
                if sideMenuManager.isSideMenuOpen {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            sideMenuManager.close() // Close when tapping outside
                        }
                        .transition(.opacity) // Fade in/out
                        .zIndex(1)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: sideMenuManager.isSideMenuOpen)
        }
        .environmentObject(sideMenuManager)
        .environmentObject(appStateManager)
        .environmentObject(accountViewModel) // Re-inject for any children
    }
}

// --- Preview for MainAppView ---
#Preview {
    MainAppView()
        .environmentObject(AppStateManager())
        .environmentObject(SideMenuManager())
        .environmentObject(AccountViewModel())
}
