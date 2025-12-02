//
//  SideMenuComponents.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 28/10/2025.
//

import Foundation
import SwiftUI

// MARK: SideMenuRowView (Updated)
struct SideMenuRowView: View {
    let iconName: String
    let title: String
//    let isSelected: Bool // To highlight the active item
    
    // REMOVED the 'action' closure

    var body: some View {
        // CHANGED Button(action: action) to HStack
        HStack(spacing: 15) {
            Image(iconName)
                .resizable()
                .font(.body.weight(.medium)) // Matched font weigh
                .frame(width: 27,height: 25) // Fixed width

            Text(title)
                .font(.PoppinsMedium(size: 15))
                .foregroundColor( .black)

            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor( .white.opacity(0.7) )
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 15) // Indent content
//        .background(
//            ZStack { // ZStack for background
//                if isSelected {
//                    LinearGradient(
//                        colors: [.skyblue, .accentPurple], // Your colors
//                        startPoint: .leading, endPoint: .trailing
//                    )
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                } else {
//                    Color.clear // Transparent when not selected
//                }
//            }
//        )
        // .animation(.none, value: isSelected) // Removed, let parent handle animation
    }
}

// MARK: SideMenu Items




// You can reuse your AppTab enum or create a new one
enum SideMenuPage {
    case home, server, account, settings, premium, feedback, terms, about
}


struct SideMenu: View {
    @EnvironmentObject var sideMenuManager: SideMenuManager
    @EnvironmentObject var appStateManager: AppStateManager
    
    // --- 1. THIS IS THE FIRST FIX ---
    // Tell SideMenu to receive the shared view model
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @State private var activePage: SideMenuPage = .home
    @State private var isShowingLogoutAlert = false
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // --- Header ---
            HStack(alignment: .top) {
                Image(.logo) // Your app logo asset
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing:0) {
                        Text("Ovvio ")
                            .font(.PoppinsBold(size: 18))
                        .foregroundColor(.skyblue)
                        Text("VPN")
                            .font(.PoppinsBold(size: 18))
                        .foregroundColor(.accentColor)
                    }
                    Text("Rule Your Connection")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
               
            }
            .padding(.horizontal, 20)
            .padding(.top, 60) // Padding for status bar
            .padding(.bottom, 30)

            // --- Menu Items ---
            ScrollView {
                VStack(spacing: 10) { // Using standard 10pt spacing
                    
                    // --- 1. "Home" Row (uses a BUTTON) ---
                    Button {
                        activePage = .home
                        sideMenuManager.close()
                    } label: {
                        SideMenuRowView(
                            iconName: "home",
                            title: "Home"
//                            isSelected: activePage == .home
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // --- 2. "Server" Row (uses a NAVIGATION LINK) ---
                    NavigationLink {
                        ServerListView()
                            .navigationBarHidden(true)
                    } label: {
                        SideMenuRowView(
                            iconName: "server",
                            title: "Server"
//                            isSelected: activePage == .server
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(TapGesture().onEnded {
                        activePage = .server
                        sideMenuManager.close()
                    })
                    
                    // --- 3. "My Account" Row (uses a NAVIGATION LINK) ---
                    
                    // --- 2. THIS IS THE SECOND FIX ---
                    NavigationLink {
                        // AccountView will now find the 'accountViewModel'
                        // in the environment automatically.
                        AccountView()
                            .navigationBarHidden(true)
                    } label: {
                        SideMenuRowView(
                            iconName: "account",
                            title: "My Account"
//                            isSelected: activePage == .account
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(TapGesture().onEnded {
                        activePage = .account
                        sideMenuManager.close()
                    })
                    
                    // --- 4. "Setting" Row (uses a NAVIGATION LINK) ---
                    NavigationLink {
                        SecuritySettingsView() // Your destination
                            .navigationBarHidden(true)
                    } label: {
                        SideMenuRowView(
                            iconName: "settings",
                            title: "Setting"
//                            isSelected: activePage == .settings
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(TapGesture().onEnded {
                        activePage = .settings
                        sideMenuManager.close()
                    })
                    
                    NavigationLink {
                        PremiumView() // Your destination
                            .navigationBarHidden(true)
                    } label: {
                        SideMenuRowView(
                            iconName: "daimond",
                            title: "Premium Plan"
//                            isSelected: activePage == .premium
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(TapGesture().onEnded {
                        activePage = .premium
                        sideMenuManager.close()
                    })
                    
                    
                    NavigationLink {
                        FeedbackView() // Your destination
                            .navigationBarHidden(true)
                    } label: {
                        SideMenuRowView(
                            iconName: "feedback",
                            title: "Feedback"
//                            isSelected: activePage == .feedback
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(TapGesture().onEnded {
                        activePage = .feedback
                        sideMenuManager.close()
                    })
                    
                    Link(destination: URL(string: "https://www.google.com")!) {
                        SideMenuRowView(iconName: "privacyPolicy", title: "Terms & Conditions"
//                                        , isSelected: false
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(TapGesture().onEnded({
                        sideMenuManager.close()
                    }))
                    
                    
                    NavigationLink {
                        AboutUsView() // Your destination
                            .navigationBarHidden(true)
                    } label: {
                        SideMenuRowView(
                            iconName: "aboutUs",
                            title: "About Us"
//                            isSelected: activePage == .about
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(TapGesture().onEnded {
                        activePage = .about
                        sideMenuManager.close()
                    })
                }
                .padding(.horizontal, 10)
            }
            
            Spacer()

            // --- Logout Button ---
            Button(action: {
                // This action no longer logs out.
                // It just tells the view to show the confirmation alert.
                isShowingLogoutAlert = true
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.right.square.fill") // Icon matches screenshot
                    Text("Logout")
                }
                .font(.headline.weight(.bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(LinearGradient(colors: [.skyblue, .accentPurple], startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            // --- Footer ---
            VStack(spacing: 5) {
                Text("Ovvio VPN v1.0.0")
                    .font(.PoppisRegular(size: 15))
                    .foregroundColor(.secondary)
                Text("© 2025 Ovvio VPN. All rights reserved.")
                    .font(.PoppisRegular(size: 12))
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 30) // Padding for home indicator

        } // End Main VStack
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground).ignoresSafeArea())
        
        // --- THIS IS THE MISSING PIECE ---
        // This watches the 'alertDetails' in your SideMenuManager
        // and presents your custom alert when it's not nil.
        .alert("Are you sure you want to log out?", isPresented: $isShowingLogoutAlert) {
                    // Button 1: Destructive action
                    Button("Logout", role: .destructive) {
                        // This is where the *actual* logout logic now lives
                        sideMenuManager.close()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            appStateManager.logout()
                        }
                    }
                    
                    // Button 2: Cancel action
                    Button("Cancel", role: .cancel) {
                        // This button automatically sets isShowingLogoutAlert = false
            }
        }
    }
}


#Preview{
    SideMenu()
        .environmentObject(SideMenuManager())  // <-- ADD FOR PREVIEW
        .environmentObject(AppStateManager())    // <-- ADD FOR PREVIEW
        .environmentObject(AccountViewModel()) // <-- ADD FOR PREVIEW
}


// --- Reusable Row for Side Menu ---
struct SideMenuRow: View {
    // This looks like a duplicate of 'SideMenuRowView'
    // You should probably delete this struct and only use 'SideMenuRowView'
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.body.weight(.medium))
                    .foregroundColor(isSelected ? .white : Color(.secondaryLabel))
                    .frame(width: 24)

                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundColor(isSelected ? .white : Color(.label))
                
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.7) : Color(.tertiaryLabel))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 15)
            .background(
                // Selected state background
                ZStack {
                    if isSelected {
                        LinearGradient(
                            colors: [.skyblue, .accentPurple],
                            startPoint: .leading, endPoint: .trailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.none, value: isSelected) // Prevent row from animating
    }
}
