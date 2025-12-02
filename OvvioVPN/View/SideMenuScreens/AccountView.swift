//
//  AccountView.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 28/10/2025.
//

// AccountView.swift
import SwiftUI

struct AccountView: View {
    // Needs dismiss if presented modally or pushed
    @Environment(\.dismiss) var dismiss
    
    // --- 1. GET THE GLOBAL APP STATE ---
    @EnvironmentObject var appStateManager: AppStateManager
    
    // --- 2. GET THE SHARED VIEWMODEL ---
    // (This is now injected from MainAppView)
    @EnvironmentObject var viewModel: AccountViewModel

    var body: some View {
        VStack(spacing: 0) { // Main container, control spacing with padding

            // --- Custom Header ---
            AccountHeaderView() // Separate header view

            // --- Scrollable Content ---
            ScrollView {
                VStack(spacing: 25) { // Spacing between sections

                    // --- 3. TYPO FIX ---
                    AccountStatusBanner(isPremium: appStateManager.isPremium)

                    // --- Personal Details Card ---
                    VStack(alignment: .leading, spacing: 0) {
                        ProfileDetailRowView(
                            iconName: "person.fill",
                            title: "Personal Details",
                            subtitle: "",
                            isHeader: true
                        )
                        .padding([.top, .horizontal]) // Padding for header row
                        .padding(.bottom, 10)

                        Divider().padding(.leading, 60) // Indented divider

                        ProfileDetailRowView(
                            iconName: "person.circle",
                            title: viewModel.user?.name ?? "Loading...", // Use ViewModel data
                            subtitle: "Username"
                        )
                        .padding([.vertical, .horizontal])

                        Divider().padding(.leading, 60)

                        ProfileDetailRowView(
                            iconName: "envelope.fill",
                            title: viewModel.user?.email ?? "Loading...", // Use ViewModel data
                            subtitle: "Email address"
                        )
                        .padding([.vertical, .horizontal])

                        Divider().padding(.leading, 60)

                        ProfileDetailRowView(
                            iconName: "calendar",
                            title: viewModel.user?.emailVerifiedAt ?? "Loading...", // Use ViewModel data
                            subtitle: "Member since"
                        )
                        .padding([.vertical, .horizontal])

                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.secondarySystemGroupedBackground)) // Card background
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
                    )


                    // --- 4. PASS THE LIVE SUBSCRIPTION ---
                    // (This code is already correct)
                    CurrentPlanView(subscription: viewModel.subscription)

                } // End content VStack
                .padding() // Padding around ScrollView content

            } // End ScrollView

        } // End Main VStack
        .background(Color(.systemGroupedBackground).ignoresSafeArea()) // Use adaptive background for whole screen
        .navigationBarHidden(true) // Hide default bar because we have a custom header
        
        // --- 5. REMOVED THE .task MODIFIER ---
        // (This view no longer fetches its own data)
    }
}

// --- Custom Header for Account Screen ---
struct AccountHeaderView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        HStack {
            Button {
                dismiss() // Action for back button
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.weight(.medium))
                    .foregroundColor(.primary) // Adaptive color
                    .padding(8) // Increase tap area
                  // Background like screenshot
                    .clipShape(Circle())
            }

            Spacer()
            Text("Account")
                .font(.PoppinsSemiBold(size: 20)) // Adjust font as needed
                .foregroundColor(.primary)
            Spacer()

            // Invisible placeholder to balance the back button
            Circle().fill(Color.clear).frame(width: 40, height: 40)
        }
        .padding(.horizontal)
        .padding(.top, 5) // Adjust top padding
        .padding(.bottom, 10)
    }
        
}


// --- Keep Placeholders & Previews ---

#Preview {
    // Wrap in NavigationStack for Preview as AccountView expects to be pushed
    NavigationStack {
        AccountView()
            // --- 6. UPDATE PREVIEW ---
            .environmentObject(AppStateManager()) // Add for the view
            .environmentObject(AccountViewModel()) // Add for the view
    }
}
