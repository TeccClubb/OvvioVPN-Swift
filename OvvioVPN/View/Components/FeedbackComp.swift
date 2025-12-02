//
//  FeedbackComp.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 28/10/2025.
//

import Foundation
import SwiftUI

//MARK: Feedback Header
struct FeedbackHeaderView: View {
    let title: String
    let backAction: () -> Void

    var body: some View {
        HStack {
            Button(action: backAction) {
                Image(systemName: "chevron.left")
                    .font(.title2.weight(.medium))
                    .foregroundColor(Color(.label)) // Adaptive color
                    .padding(8)
                    .clipShape(Circle())
            }

            Spacer()
            Text(title)
                .font(.PoppinsSemiBold(size: 20)) // Or your custom font
                .foregroundColor(Color(.label))
            Spacer()

            // Invisible placeholder to balance layout
            Circle().fill(Color.clear).frame(width: 40, height: 40)
        }
        .padding(.horizontal)
        .padding(.top, 5)
        .padding(.bottom, 10)
    }
}

//MARK: StarRating

struct StarRatingView: View {
    @Binding var rating: Int // 1 to 5, 0 = not set
    let maxRating: Int = 5
    let starSize: CGFloat = 35 // Size of the stars

    var body: some View {
        HStack(spacing: 15) { // Spacing between stars
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index > rating ? "star" : "star.fill") // Empty or Filled star
                    .font(.system(size: starSize))
                    .foregroundColor(index > rating ? Color(.systemGray3) : .yellow) // Gray or Yellow
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            // Allow tapping the same star to reset to 0
                            rating = (index == rating) ? 0 : index
                        }
                    }
            }
        }
    }
}

//MARK: RateTopicRow


struct RateTopicRowView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(.label)) // Adaptive color

                Spacer()

                // Custom radio button
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color(.systemGray3), lineWidth: 2) // Use your accent color
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color.blue) // Use your accent color
                            .frame(width: 14, height: 14)
                            .transition(.scale.animation(.spring())) // Animate appearance
                    }
                }
            }
            .padding(.vertical, 10) // Add vertical padding for larger tap area
        }
        .buttonStyle(PlainButtonStyle()) // Use plain style for custom button
    }
}

