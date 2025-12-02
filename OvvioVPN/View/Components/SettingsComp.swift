//
//  SettingsComp.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 28/10/2025.
//

import SwiftUI

// Reusing the enum, ensure it's accessible
enum SettingsRowType {
    case navigation(detail: String? = nil)
    case toggle(isOn: Binding<Bool>)
}

struct SettingsRowView: View {
    let iconName: String // SF Symbol name
    let title: String
    let subtitle: String? // Add optional subtitle
    let rowType: SettingsRowType
    let iconBackgroundColor: Color // Main color for icon circle

    // Default initializer
    init(iconName: String, title: String, subtitle: String? = nil, rowType: SettingsRowType, iconBackgroundColor: Color) {
        self.iconName = iconName
        self.title = title
        self.subtitle = subtitle
        self.rowType = rowType
        self.iconBackgroundColor = iconBackgroundColor
    }

    var body: some View {
        HStack(spacing: 15) {
            // MARK: - Icon
            ZStack {
                // Use Circle background
                Circle()
                    .fill(iconBackgroundColor.opacity(0.15)) // Light tint background
                    .frame(width: 40, height: 40)

                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .medium)) // Adjust icon size
                    .foregroundColor(iconBackgroundColor) // Icon color matches tint
            }
            .frame(width: 40, height: 40) // Fixed size for alignment

            // MARK: - Title & Subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium)) // Slightly bolder title
                    .foregroundColor(Color(.label)) // Adaptive text color

                // Display subtitle if provided
                if let subtitleText = subtitle {
                    Text(subtitleText)
                        .font(.caption)
                        .foregroundColor(.secondary) // Adaptive gray
                }
            }

            Spacer() // Pushes title left, trailing element right

            // MARK: - Trailing Element
            switch rowType {
            case .navigation(let detail):
                HStack(spacing: 6) {
                    if let detailText = detail {
                        Text(detailText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray.opacity(0.5)) // Lighter chevron
                }
            case .toggle(let isOnBinding):
                Toggle("", isOn: isOnBinding)
                    .labelsHidden()
                    // Use blue tint matching the screenshot
                    .tint(LinearGradient(colors: [Color.accentColor,.skyblue], startPoint: .leading, endPoint: .trailing)) // Apply tint directly
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 15)
        .background(Color(.secondarySystemGroupedBackground)) // Row background
        .clipShape(RoundedRectangle(cornerRadius: 16)) // More rounded corners
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2) // Subtle shadow
    }
}
