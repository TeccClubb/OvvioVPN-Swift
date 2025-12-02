import SwiftUI
import Foundation


struct ServerListView: View {
    
    @EnvironmentObject var appStateManager: AppStateManager
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = ServerListViewModel()
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                
                CustomNavBar()
                
                // Search
                SearchCountryView(searchText: $viewModel.searchText)
                
                // Quick Actions
                Text("Quick Actions")
                    .font(.PoppinsBold(size: 20))
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    
                    // Fastest server
                    ActionRow(
                        iconName: "fast",
                        title: "Fastest Free Server",
                        subtitle: "Connect to the fastest available server",
                        iconColor: .blue,
                        isSelected: viewModel.quickSelection == .fastest
                    )
                    .onTapGesture {
                        viewModel.handleFastestServerTap {
                            dismiss()
                        }
                    }
                    
                    // Random location
                    ActionRow(
                        iconName: "random",
                        title: "Random Location",
                        subtitle: "Connect to a random server",
                        iconColor: .blue,
                        isSelected: viewModel.quickSelection == .random
                    )
                    .onTapGesture {
                        viewModel.handleRandomServerTap {
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal)
                
                // Tabs (All, Premium, Favorite)
                ServerTabsView(selectedTab: $viewModel.selectedTab)
                
                // Main List Area
                if viewModel.isLoading && viewModel.filteredServers.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)     // <-- Centers horizontally
                }
                else if let error = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        Text(error)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)      // <-- Centers horizontally
                }
 else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(viewModel.filteredServers) { server in
                                
                                let ping = viewModel.pingResults[server.id] ?? -1
                                
                                ServerRowView(
                                    server: server,
                                    isFavourite: viewModel.favouriteServerIDs.contains(server.id),
                                    ping: ping,
                                    isSelected: viewModel.selectedServerID == server.id
                                )
                                .onTapGesture {
                                    let ok = viewModel.selectServer(server)
                                    if ok { dismiss() }
                                }
                                .overlay(alignment: .trailing) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(
                                            viewModel.favouriteServerIDs.contains(server.id) ? .yellow : .gray.opacity(0.3)
                                        )
                                        .padding(.horizontal, 20)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            viewModel.toggleFavourite(for: server)
                                        }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
                
                Spacer()
            }
        }
        .task {
            viewModel.setAppStateManager(appStateManager)
        }
        .sheet(isPresented: $viewModel.showPremiumPopup) {
            PremiumView()
                .environmentObject(appStateManager)
        }
    }
}


// MARK: - Reusable Subviews
// (CustomNavBar, SearchCountryView, ActionRow, RadioButtonView, ServerTabsView, TabButton...
// ...all remain the same as your code)

/// Custom Navigation Bar (Static View)
struct CustomNavBar: View {
    @Environment (\.dismiss) var dismiss
    var body: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2.weight(.medium))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Text("Server")
                .font(.PoppinsSemiBold(size: 20))
            
            Spacer()
            
            // Placeholder for equal spacing
            Image(systemName: "chevron.left")
                .font(.title2.weight(.medium))
                .foregroundColor(.clear)
        }
        .padding(.horizontal)
        .padding(.top, 10) // Adjust top padding as needed
    }
}

/// Search Bar View (Bound View)
struct SearchCountryView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.title3)
            
            TextField("Search Country", text: $searchText)
                .font(.system(size: 18))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 5)
        .padding(.horizontal)
    }
}

/// Quick Action Row View (Static View)
struct ActionRow: View {
    let iconName: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(iconName)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.PoppinsMedium(size: 15))
                
                Text(subtitle)
                    .font(.PoppisRegular(size: 10))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            RadioButtonView(isSelected: isSelected)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 5)
    }
}

/// Custom Radio Button (Static View)
struct RadioButtonView: View {
    let isSelected: Bool
    
    var body: some View {
        Circle()
            .stroke(isSelected ? .blue : Color.gray.opacity(0.3), lineWidth: 2)
            .frame(width: 24, height: 24)
            .overlay(
                // Show inner dot if selected
                Circle()
                    .fill(isSelected ? .blue : Color.clear)
                    .padding(6)
            )
    }
}

/// Server Tab Selection View (Bound View)
struct ServerTabsView: View {
    @Binding var selectedTab: ServerTab
    
    var body: some View {
            HStack(spacing: 12) {
                ForEach(ServerTab.allCases, id: \.self) { tab in
                    TabButton(
                        title: tab.rawValue,
                        isSelected: selectedTab == tab,
                        action: {
                            withAnimation(.spring()) {
                                selectedTab = tab
                            }
                        }
                    )
                }
            }.frame(height: 50)
            .padding(.horizontal)
    }
}

/// Custom Tab Button (Static View with Action)
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.PoppinsMedium(size: 12))
                .padding(.horizontal, 24) // <-- This is the fixed line
                .padding(.vertical, 12)   // <--
                .background(isSelected ? LinearGradient(colors: [.skyblue,.accentPurple], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [Color.gray.opacity(0.2)], startPoint: .leading, endPoint: .trailing))
                .foregroundColor(isSelected ? .white : .black.opacity(0.7))
                .cornerRadius(20)
        }
    }
}


// --- 10. COMPLETELY REFACTORED SERVER ROW VIEW ---
struct ServerRowView: View {
    let server: DisplayableServer // <-- 1. Accept the new struct
    let isFavourite: Bool
    let ping: Double
    let isSelected : Bool
    // 'onToggleFavourite' is removed, handled by the parent view's overlay
    
    var body: some View {
        HStack(spacing: 12) {
            // AsyncImage: Use the PARENT (country) image
            AsyncImage(url: URL(string: server.country.image)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
            }
            
            // VStack: Show Country and City
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    // Show the CHILD (city) name
                    Text(server.subServer.name)
                        .font(.PoppinsMedium(size: 15))
                    
                    // Show the PARENT (country) premium status
                    if server.country.type == .premium {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                // Show the PARENT (country) name as the subtitle
                Text(server.country.name)
                    .font(.PoppisRegular(size: 15))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // --- 10. UPDATED PING DISPLAY ---
            HStack(spacing: 6) {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.subheadline)
                
                if ping == -2.0 { // Pinging...
                    Text("Pinging...")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                } else if ping == -1.0 { // Error
                    Text("N/A")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                } else { // Success
                    Text(String(format: "%.0f ms", ping))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(pingColor(for: Int(ping)))
                }
            }
            
            // Favourite Star (this is just a placeholder to keep spacing)
            Image(systemName: "star.fill")
                .font(.title3)
                .padding(.leading, 8)
                .opacity(0) // It's invisible
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .overlay( RoundedRectangle(cornerRadius: 20)
            .stroke(isSelected ? .blue : Color.clear, lineWidth: 2.5)
                )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 5)
    }
    
    /// Helper function to determine ping color
    private func pingColor(for pingInMs: Int) -> Color {
        if pingInMs <= 200 {
            return .green // Very fast
        } else if pingInMs <= 251 {
            return .orange // Average
        } else {
            return .red // Slow
        }
    }
}

// MARK: - Preview
struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        ServerListView()
            // --- 4. UPDATE PREVIEW ---
            .environmentObject(AppStateManager())
    }
}
