//
//  SecuritySettingsView.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 28/10/2025.
//

import SwiftUI

struct SecuritySettingsView: View {
    @Environment(\.dismiss) var dismiss // For back button
    // State for toggles
    @AppStorage("autoConnectEnabled") var autoConnectEnabled = false
    @AppStorage("killSwitchEnabled") var killSwitchEnabled = false
//    @State private var isAutoConnectOn = true
//    @State private var isKillSwitchOn = true
    // State for selected protocol (replace with actual logic)
    @State private var selectedProtocol = "Ikev2"

    var body: some View {
        VStack(spacing: 0) { // Main VStack, control spacing with padding

            // --- Custom Header ---
            SecurityHeaderView(title: "Security Setting") {
                dismiss() // Action for back button
            }

            // --- Scrollable Settings List ---
            ScrollView {
                VStack(spacing: 15) { // Spacing between rows/cards

                    // --- Auto-Connect ---
                    SettingsRowView(
                        iconName: "wifi",
                        title: "Auto-Connect",
                        subtitle: "Connect on untrusted networks",
                        rowType: .toggle(isOn: $autoConnectEnabled),
                        iconBackgroundColor: .blue // Example color
                    )

                    // --- Connection Protocol ---
                    // Wrap in NavigationLink
                    
                    // use Navigation Link when Protocol are availabe
                    Button {
                         // Destination view (e.g., SelectProtocolView)
                         print("Protocol selection view") // Ensure this view exists
                    } label: {
                         SettingsRowView(
                             iconName: "shield.lefthalf.filled", // Example icon
                             title: "Connection Protocol",
                             subtitle: selectedProtocol, // Show selected protocol
                             rowType: .navigation(), // Indicate navigation
                             iconBackgroundColor: .indigo // Example color
                         )
                    }
                    .buttonStyle(PlainButtonStyle()) // Maintain row style

                    // --- Kill Switch ---
                    SettingsRowView(
                        iconName: "power",
                        title: "Kill Switch",
                        subtitle: "Block internet if VPN disconnects",
                        rowType: .toggle(isOn: $killSwitchEnabled),
                        iconBackgroundColor: .red // Example color
                    )

                    // --- Split Tunneling ---
//                    NavigationLink {
//                        // Destination view (e.g., SplitTunnelingView)
//                         Text("Split Tunneling Screen") // Placeholder
//                    } label: {
//                        SettingsRowView(
//                            iconName: "tuningfork", // Example icon
//                            title: "Split Tunneling",
//                            subtitle: "Exclude apps from VPN",
//                            rowType: .navigation(),
//                            iconBackgroundColor: .orange // Example color
//                        )
//                    }
//                    .buttonStyle(PlainButtonStyle())

                    // --- Security Audit ---
//                    NavigationLink {
//                        // Destination view (e.g., SecurityAuditView)
//                         Text("Security Audit Screen") // Placeholder
//                    } label: {
//                        SettingsRowView(
//                            iconName: "checkmark.shield", // Example icon
//                            title: "Security Audit",
//                            subtitle: "Check system for vulnerabilities",
//                            rowType: .navigation(),
//                            iconBackgroundColor: .purple // Example color
//                        )
//                    }
//                    .buttonStyle(PlainButtonStyle())


                } // End Rows VStack
                .padding() // Padding around the list content

            } // End ScrollView

        } // End Main VStack
        .background(Color(.systemBackground).ignoresSafeArea()) // Use adaptive system background
        .navigationBarHidden(true) // Hide default bar
    }
}


// --- Custom Header Component ---
struct SecurityHeaderView: View {
    let title: String
    let backAction: () -> Void

    var body: some View {
        HStack {
            Button(action: backAction) {
                Image(systemName: "chevron.left")
                    .font(.title2.weight(.medium))
                    .foregroundColor(.primary) // Adaptive color
                    .padding(8)
                    .clipShape(Circle())
            }

            Spacer()
            Text(title)
                .font(.PoppinsSemiBold(size: 20)) // Adjust font
                .foregroundColor(.primary)
            Spacer()

            // Invisible placeholder to balance layout
            Circle().fill(Color.clear).frame(width: 40, height: 40)
        }
        .padding(.horizontal)
        .padding(.top, 5)
        .padding(.bottom, 10)
    }
}


// --- Keep Placeholders & Previews ---


#Preview {
    // Wrap in NavigationStack for Preview as rows might navigate
    NavigationStack {
        SecuritySettingsView()
             // Add environment objects if needed by destination views
            .environmentObject(AppStateManager()) // Example
    }
}
