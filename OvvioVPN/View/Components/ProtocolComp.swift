//
//  ProtocolComponents.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 28/10/2025.
//

import Foundation
import SwiftUI


//MARK: Ainmated Border

struct AnimatedGradientBorder : View {
    let cornerRadius : CGFloat
    let lineWidth : CGFloat
    let gradientColors : [Color] = [.skyblue,.accentPurple]
    @State private var rotation : Double = 0
    
    var body: some View{
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(
            AngularGradient(gradient:
                                Gradient(colors: gradientColors),
                            center: .center,
                            angle: .degrees(rotation))
            )
            .onAppear{
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

//MARK: ProtocolCardView.swift

struct ProtocolCardView: View {
    let protocolInfo: ProtocolInfo
    @Binding var selectedProtocolId: UUID? // Binding to the ID
    let cornerRadius: CGFloat = 20 // Consistent corner radius

    private var isSelected: Bool {
        selectedProtocolId == protocolInfo.id
    }

    var body: some View {
        HStack(spacing: 15) {
            // MARK: - Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12) // Slightly less rounded than card
                    .fill(Color.accentPurple.opacity(0.8)) // Use your purple color
                    .frame(width: 50, height: 50)

                Image(protocolInfo.iconName) // Your custom asset name
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
            }

            // MARK: - Text Content & Strength
            VStack(alignment: .leading, spacing: 5) {
                Text(protocolInfo.name)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.primary) // Use semantic color

                Text(protocolInfo.description)
                    .font(.caption)
                    .foregroundColor(.secondary) // Adaptive gray
                    .lineLimit(2) // Allow two lines
                    .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion

                // Strength Dots
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Circle()
                            // Fill green if index < strength, otherwise gray
                            .fill(index < protocolInfo.strength ? Color.green : Color(.systemGray4))
                            .frame(width: 6, height: 6)
                    }
                }
            } // End Text VStack

            Spacer() // Pushes content left, selector right

            // MARK: - Selection Indicator (Radio Button Style)
            ZStack {
                Circle()
                    // Use accent color for border when selected
                    .stroke(isSelected ? Color.accentPurple : Color(.systemGray4), lineWidth: 2)
                    .frame(width: 24, height: 24)

                if isSelected {
                    Circle()
                        .fill(Color.accentPurple) // Fill when selected
                        .frame(width: 16, height: 16)
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected) // Animate checkmark appearance

        } // End Main HStack
        .padding(15) // Internal padding
        .background(Color(.secondarySystemGroupedBackground)) // Card background
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay( // Overlay for border
            // Conditionally show animated border
            ZStack {
                if isSelected {
                    AnimatedGradientBorder(cornerRadius: cornerRadius, lineWidth: 2.5) // Animated border
                } else {
                    // Faint static border when not selected
                    RoundedRectangle(cornerRadius: cornerRadius)
                         .stroke(Color(.systemGray4).opacity(0.5), lineWidth: 1)
                }
            }
        )
        .contentShape(Rectangle()) // Make whole area tappable
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedProtocolId = protocolInfo.id // Update selection
            }
        }
        // Animate overall changes smoothly
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
