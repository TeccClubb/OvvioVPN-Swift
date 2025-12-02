//
//  HomeView.swift
//  OvvioVPN
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = MainViewModel()
    
    // --- Global Managers ---
    @EnvironmentObject var appStateManager: AppStateManager
    @EnvironmentObject var sideMenuManager: SideMenuManager
    @EnvironmentObject var accountViewModel: AccountViewModel
    @StateObject private var serverViewModel = ServerListViewModel()
    
    var body: some View {
        ZStack {
            // --- Background ---
            Image(.worldmap)
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.white.opacity(0.1), Color.cyan.opacity(0.1)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            // --- Main Content Layout ---
            VStack(spacing: 0) {
                
                // 1. HEADER (Fixed at Top)
                HeaderView(
                    openPremiumAction: viewModel.openPremiumView
                )
                
                Divider()
                    .opacity(0) // Invisible divider for spacing
                
                // 2. CONTENT (Stacked vertically)
                VStack(spacing: 25) { // Adjust this spacing if content gets cut off on small screens
                    
                    // --- Auto Select Button ---
                    NavigationLink {
                        ServerListView()
                            .environmentObject(appStateManager)
                    } label: {
                        AutoSelectButtonView(action: {
                            Task {
                                // 1. Disconnect if already connected
                                if viewModel.isConnected {
                                    await viewModel.disconnectAndWait()
                                }

                                // 2. Pick random server
                                if let randomServer = serverViewModel.randomServer() {
                                    let ok = serverViewModel.selectServer(randomServer)

                                    // 3. Connect to the new server
                                    if ok { viewModel.connect() }
                                }
                            }
                        })
                        .padding(.top, 20)

                    }
                    .buttonStyle(PlainButtonStyle())

                    // --- Connection Status ---
                    ConnectionStatusView(isConnected: viewModel.isConnected)
                    
                    // --- Connection Slider ---
                    ConnectionButtonSliderView(
                        connectionState: $viewModel.connectionState,
                        action: viewModel.toggleConnection
                    )

                    // --- Timer OR Small Gap ---
                    if viewModel.isConnected {
                        ConnectionTimerView(formattedTime: viewModel.formattedTime)
                            .transition(.opacity.animation(.easeInOut))
                    } else {
                        // Reduced fixed spacer so it fits on iPhone SE
                        Spacer().frame(height: 20)
                    }

                    // --- Security Status ---
                    SecurityStatusView(isConnected: viewModel.isConnected)

                    // --- Bottom Card ---
                    Group {
                        if viewModel.isConnected, let server = viewModel.selectedServerInfo {
                            ConnectedServerView(server: server)
                                .transition(.opacity.animation(.easeInOut))
                            
                        } else if !appStateManager.isPremium {
                            PremiumUpsellView(action: viewModel.openPremiumView)
                                .transition(.opacity.animation(.easeInOut))
                        }
                        // Removed the Spacer().frame(height: 100) else block to save space
                    }
                    
                } // End Content VStack
                .padding()
                
                // 3. THE FIX: SPACER AT THE BOTTOM
                // This pushes the VStack to fill the screen height,
                // forcing the Header to the top.
                Spacer(minLength: 0)
                
            } // End Main VStack
        }
        .navigationBarHidden(true)
        
        // --- Modifiers ---
        .navigationDestination(isPresented: $viewModel.shouldShowPremium) {
            PremiumView().environmentObject(appStateManager)
        }
        .sheet(isPresented: $viewModel.showServerList) {
            NavigationStack {
                ServerListView().environmentObject(appStateManager)
            }
        }
        .task {
            viewModel.setAppStateManager(appStateManager)
            accountViewModel.setAppStateManager(appStateManager)
            accountViewModel.getUser()
            accountViewModel.getSubscription()
            viewModel.checkAutoConnect()
        }
    }
}

// --- Preview ---
#Preview {
    HomeView()
        .environmentObject(AppStateManager())
        .environmentObject(SideMenuManager())
        .environmentObject(AccountViewModel())
}
