//
//  OboardingComp.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 27/10/2025.
//

import Foundation
import SwiftUI

struct OnboardingPageView: View {
    let data: OnboardingPageData

    var body: some View {
        VStack(spacing: 30) { // Main spacing for elements
            Spacer() // Pushes content down slightly

            // --- Image ---
            Image(data.imageName) // Use your asset name
                .resizable()
                .scaledToFit()
                // Adjust height based on screen or fixed value
                .frame(height: UIScreen.main.bounds.height * 0.3)
                .padding(.horizontal, 20)
                // Add feature tags overlay if they exist
                

            Spacer() // Creates space between image and text

            // --- Title ---
            VStack { // Group title parts
                Text(data.titlePart1)
                // Add second part if it exists, with different color
                if let titlePart2 = data.titlePart2 {
                    Text(titlePart2)
                        .foregroundColor(.skyblue) // Use your skyblue color
                }
            }
            .font(.PoppinsBold(size: 35)) // Adjust font
            .multilineTextAlignment(.center)
            .foregroundColor(Color(.label)) // Adaptive text color
            .padding(.horizontal, 30)

            // --- Description ---
            Text(data.description)
                .font(.PoppisRegular(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 400) // keeps lines from stretching too wide
                .padding(.horizontal, 20)

            Spacer() // Pushes text content up slightly
            Spacer() // Add more space towards the bottom
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Optional: Separate view for feature tag overlay (used on page 2 & 3)
struct FeatureTagsOverlay: View {
    let tags: [FeatureTag]?

    // Define positions (adjust these based on your image dimensions/layout)
    private let positions: [UnitPoint] = [.topLeading, .topTrailing, .bottomLeading, .bottomTrailing, .center]

    var body: some View {
        // Only show if tags exist
        if let tags = tags {
            GeometryReader { geometry in
                ZStack {
                    ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                        // Basic positioning example - refine as needed
                        let alignment = unitPoint(for: index)
                        let xOffset: CGFloat = (alignment.x - 0.5) * (geometry.size.width * 0.4) // Adjust multiplier
                        let yOffset: CGFloat = (alignment.y - 0.5) * (geometry.size.height * 0.4) // Adjust multiplier

                        FeatureTagView(tag: tag)
                            .offset(x: xOffset, y: yOffset)
                            // Add connection lines if needed (more complex)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } else {
            EmptyView() // No tags, show nothing
        }
    }

    // Helper to map index to an alignment point
    func unitPoint(for index: Int) -> UnitPoint {
        switch index % 4 { // Cycle through 4 main positions
        case 0: return .topLeading
        case 1: return .topTrailing
        case 2: return .bottomLeading
        case 3: return .bottomTrailing
        default: return .center // Fallback
        }
    }
}

// View for a single feature tag bubble
struct FeatureTagView: View {
    let tag: FeatureTag

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: tag.iconName)
                .font(.caption.weight(.medium))
            Text(tag.text)
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .foregroundColor(Color(.label)) // Adaptive text
        .background(.regularMaterial) // Blur background
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
}
