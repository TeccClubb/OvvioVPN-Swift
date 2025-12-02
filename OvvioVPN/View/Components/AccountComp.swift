//
//  AccountComp.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 28/10/2025.
//

import Foundation
import SwiftUI
//MARK: ProfileDetailRowView


struct ProfileDetailRowView: View {
    let iconName: String
    let title: String
    let subtitle: String
    let isHeader: Bool // For "Personal Details" styling
    
    init(iconName: String, title: String, subtitle: String, isHeader: Bool = false) {
        self.iconName = iconName
        self.title = title
        self.subtitle = subtitle
        self.isHeader = isHeader
    }

    var body: some View {
        HStack(spacing: 16) {
            // MARK: - Icon
            ZStack {
                // Background for icon
                Circle()
                    .fill(isHeader ? Color.blue.opacity(0.1) : Color(.systemGray5)) // Blue tint for header, gray otherwise
                    .frame(width: 40, height: 40) // Slightly smaller frame

                Image(systemName: iconName)
                    .font(isHeader ? .headline : .subheadline) // Adjust icon size
                    .foregroundColor(isHeader ? .blue : .secondary) // Blue for header, gray otherwise
            }
            .frame(width: 40, height: 40)

            // MARK: - Text Content
            VStack(alignment: .leading, spacing: 2) {
                // Header style
                if isHeader {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundColor(Color(.label)) // Adaptive black/white
                } else {
                // Regular row style
                    Text(title) // Main info (username, email, date)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(.label))
                    Text(subtitle) // Label (Username, Email address)
                        .font(.caption)
                        .foregroundColor(.secondary) // Adaptive gray
                }
            }
            Spacer()
        }
    }
}

//MARK: AccountStatusBanner
struct AccountStatusBanner: View {
    
    // 1. ADD THIS PROPERTY
    let isPremium: Bool

    var body: some View {
        HStack(spacing: 12) {
            // 2. MAKE THE VIEW DYNAMIC
            Image(systemName: isPremium ? "sparkles" : "shield.slash")
                .font(.title2.weight(.semibold))
                .foregroundColor(isPremium ? .orange : .red) // Dynamic color

            VStack(alignment: .leading, spacing: 2) {
                Text(isPremium ? "Premium Plan" : "Free Plan") // Dynamic text
                    .font(.headline.weight(.bold))
                    .foregroundColor(.primary)
                Text(isPremium ? "You have unlocked all features." : "Upgrade to unlock all features.") // Dynamic text
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
        )
    }
}

//MARK:  CurrentPlanView

struct CurrentPlanView: View {
    
    // --- 1. REMOVED VIEWMODEL ---
    // @StateObject private var viewModel = AccountViewModel()
    
    // --- 2. ADDED INPUT PROPERTY ---
    // This view now gets its data from the parent (AccountView)
    let subscription: Subscription?
    
    @State private var showSub = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            // --- 3. UPDATED LOGIC ---
            // Check the 'subscription' property that was passed in
            if let sub = subscription {
                
                // --- PREMIUM USER UI ---
                
                HStack {
                    Text("Current Plan")
                        .font(.headline.weight(.bold))
                    Spacer()
                    PremiumTagOverlay()
                }

                Text(sub.plan.name)
                    .font(.title2.weight(.bold))

                Text(sub.plan.description)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Expires on")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        // --- 5. MADE DATE FORMATTING SAFE ---
                        Text(formatDate(sub.endsAt))
                            .font(.subheadline.weight(.semibold))
                    }

                    Spacer()

                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(width: 1, height: 40)
                        .padding(.horizontal)

                    Spacer()

                    VStack(alignment: .leading) {
                        Text("Auto-renewal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(sub.isRecurring ? "Enabled" : "Disabled")
                            .font(.subheadline.weight(.semibold))
                    }

                    Spacer()
                }
                .padding(.top, 5)

                // --- 4. BUTTON IS REMOVED FROM PREMIUM VIEW (as requested) ---
                
            } else {
                
                // --- 4. NEW FREE USER UI ---
                
                HStack {
                    Text("Current Plan")
                        .font(.headline.weight(.bold))
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "shield.slash.fill")
                        .font(.title)
                        .foregroundColor(.secondary)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("You are on the Free Plan")
                            .font(.headline.weight(.semibold))
                        Text("Upgrade to unlock all features.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.top, 10)
                
                Spacer()
                    .frame(height: 10)

                // --- 4. BUTTON IS ADDED TO FREE VIEW (as requested) ---
                Button("Manage Subscription") { // Text is from your request
                    showSub = true
                }
                .font(.headline.weight(.bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top, 10)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground)) // Changed for dynamic light/dark
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        // --- 5. REMOVED .onAppear ---
        .sheet(isPresented: $showSub) {
            PremiumView()
        }
    }

    // --- 5. UPDATED HELPER FUNCTION ---
    private func formatDate(_ dateString: String?) -> String {
        // Safely unwrap the optional string
        guard let dateString = dateString else { return "N/A" }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            let output = DateFormatter()
            output.dateStyle = .medium
            return output.string(from: date)
        }
        return dateString
    }
}

// (Assuming you have this view defined somewhere)
struct PremiumTagOverlay: View {
    var body: some View {
        Text("PREMIUM")
            .font(.caption.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundColor(.white)
            .background(Color.orange)
            .cornerRadius(6)
    }
}
