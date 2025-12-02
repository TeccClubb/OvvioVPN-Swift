//
//  MainComponents.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 28/10/2025.
//

import Foundation
import SwiftUI

//MARK: Header View

struct HeaderView: View {
    // Actions passed from the parent ViewModel/View
    @EnvironmentObject var sideMenuManager : SideMenuManager
    var openPremiumAction: () -> Void

    var body: some View {
        HStack {
                    // --- MODIFY THIS BUTTON ---
                    Button(action: {
                        sideMenuManager.open() // Call the manager directly
                    }) {
                        Image(.sideMenu) // Your asset
                            .resizable()
                            .frame(width: 20, height: 20) // Adjust size
                            .foregroundColor(.primary) // Use semantic color
                    }
                    // --- END MODIFICATION ---

                    Spacer()
                    Text("Ovvio VPN")
                        .font(.PoppinsMedium(size: 20))
                        .foregroundColor(.primary) // Use semantic color
                    Spacer()

                    // This NavigationLink should be in your HomeView, not HeaderView
                    // to avoid nested NavigationStacks. Let's use the closure.
                    Button(action: openPremiumAction) { // Changed back to button
                        Image(.crown) // Your asset
                            .resizable()
                            .frame(width: 30, height: 24)
                    }
                }
        .padding(.horizontal)
        .padding(.top, 5) // Adjust top padding as needed
        .padding(.bottom, 10) // Space below header
        // No Divider needed if it's just a header for this view
    }
}



// MARK:  AutoSelectButtonView

struct AutoSelectButtonView: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(.blueGlobe) 
                    .resizable()
                    .frame(width: 40,height: 40)
                Text("Auto Select")
                    .font(.PoppinsMedium(size: 15))
                Image(systemName: "chevron.right")
                    .font(.title2)
            }
            .foregroundColor(Color(.label)) // Adaptive text/icon color
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(.regularMaterial) // Blur background
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview{
    AutoSelectButtonView {
        print("hi")
    }
}

//MARK: ConnectionStatusView

struct ConnectionStatusView: View {
    let isConnected: Bool

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isConnected ? .green : .red)
                .frame(width: 10, height: 10)
            Text(isConnected ? "Connected" : "Disconnected")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.linearGradient(
            colors: [.accentPurple,.skyblue],
            startPoint: .leading,
            endPoint: .trailing)) // Blur background
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }
}



//MARK:  ConnectionButtonSliderView

struct ConnectionButtonSliderView: View {
    @Binding var connectionState: VPNConnectionState
//    @Binding var isAnimating: Bool // For connecting animation
    let action: () -> Void

    // Drag gesture state
    @GestureState private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false

    // Configuration
    private let trackWidth: CGFloat = 250
    private let trackHeight: CGFloat = 100
    private let thumbDiameter: CGFloat = 80 // Slightly smaller than height
    private let activationThreshold: CGFloat = 0.6 // Drag 60% across to activate

    // Calculated positions
    private var thumbXOffset: CGFloat {
        // Offset during drag, respecting boundaries
        let dragPosition = dragOffset
        let restingPosition = connectionState == .connected ? trackWidth - thumbDiameter - 5 : 5 // 5 is padding
        let currentVisualPosition = restingPosition + dragPosition

        // Clamp the visual position within the track bounds
        return max(5, min(trackWidth - thumbDiameter - 5, currentVisualPosition))
    }

    var body: some View {
        ZStack(alignment: .leading) {
            // --- Background Track ---
            Capsule()
                .fill(connectionState == .connected ? LinearGradient(
                    colors: [Color.skyblue,Color.accentPurple],
                    startPoint: .leading,
                    endPoint: .trailing) :
                        LinearGradient(colors: [Color.gray.opacity(0.5)],
                                       startPoint: .leading,
                                       endPoint: .trailing)) // Faint track
                .frame(width: trackWidth, height: trackHeight)

            // --- Sliding Thumb ---
            ZStack {
                Circle()
                    .fill(connectionState == .connected ? Color.white : Color.white) // Green when connected
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)

                // Icon / Progress Indicator
                if connectionState == .connecting || connectionState == .disconnecting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: connectionState == .connected ? .white : .blue))
                        .scaleEffect(1.2)
                } else {
                    Image(systemName: "power")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(connectionState == .connected ? .green : .red) // White power icon when connected
                }
            }
            .frame(width: thumbDiameter, height: thumbDiameter)
            .offset(x: thumbXOffset) // Apply calculated offset
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: thumbXOffset) // Animate movement
            .gesture(
                DragGesture(minimumDistance: 5)
                    .updating($dragOffset) { value, state, _ in
                        // Update drag offset but constrain it
                        let proposedOffset = value.translation.width
                        if connectionState == .disconnected { // Dragging right
                            state = max(0, min(trackWidth * activationThreshold, proposedOffset))
                        } else if connectionState == .connected { // Dragging left
                            state = min(0, max(-trackWidth * activationThreshold, proposedOffset))
                        } else {
                            state = 0 // Don't allow drag when connecting/disconnecting
                        }
                    }
                    .onChanged { _ in if !isDragging { isDragging = true } }
                    .onEnded { value in
                        isDragging = false
                        let dragDistance = value.translation.width
                        let thresholdDistance = trackWidth * activationThreshold

                        if connectionState == .disconnected && dragDistance > thresholdDistance {
                            action() // Connect
                        } else if connectionState == .connected && dragDistance < -thresholdDistance {
                            action() // Disconnect
                        }
                        // @GestureState resets dragOffset, spring animation handles snap back if not activated
                    }
            ) // End Gesture
            // Add chevrons inside the track (optional)
             if connectionState == .disconnected {
                 HStack {
                     Spacer()
                     Image(systemName: "chevron.right")
                     Image(systemName: "chevron.right")
                     Image(systemName: "chevron.right")
                 }
                 .font(.headline.weight(.light))
                 .foregroundColor(.gray)
                 .padding(.trailing, thumbDiameter * 0.8) // Position behind thumb
                 .allowsHitTesting(false) // Let drag gesture pass through
             } else if connectionState == .connected {
                  HStack {
                      Image(systemName: "chevron.left")
                      Image(systemName: "chevron.left")
                      Image(systemName: "chevron.left")
                      Spacer()
                  }
                  .font(.headline.weight(.light))
                  .foregroundColor(.white)
                  .padding(.leading, thumbDiameter * 0.8) // Position behind thumb
                  .allowsHitTesting(false)
             }

        } // End ZStack
        .frame(width: trackWidth, height: trackHeight) // Set size for the whole control
    }
}


//MARK:  ConnectionTimerView

struct ConnectionTimerView: View {
    let formattedTime: String

    var body: some View {
        VStack(spacing: 2) {
            Text("Connected") // Title above timer
                .font(.PoppinsMedium(size: 30))
                .foregroundColor(.primary) // Use semantic color
            Text(formattedTime)
                .font(.PoppisRegular(size: 20))
                .foregroundColor(.primary)
        }
    }
}

//MARK:  SecurityStatusView.swift
struct SecurityStatusView: View {
    let isConnected: Bool
    private var borderColor : Color{
        isConnected ? .green : .red
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isConnected ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundColor(isConnected ? .green : .red)

            VStack(alignment: .leading, spacing: 2) {
                Text(isConnected ? "SECURED" : "Unsecured Connection")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(isConnected ? .green : .red)
                Text(isConnected ? "Your connection is protected" : "Your IP address is visible to others")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Optional: 256-BIT text
            if isConnected {
                HStack(spacing: 4) {
                     Image(systemName: "questionmark.circle")
                        .foregroundColor(.green)
                        .font(.title3)
                     Text("256-BIT")
                        .foregroundStyle(.green)
                        .font(.Orbitron(size: 15))
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        
        .background(isConnected ? .green.opacity(0.1) : .clear )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
        RoundedRectangle(cornerRadius:20)
            .stroke(borderColor, lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        .animation(.easeIn(duration: 0.3))
    }
}

#Preview{
    SecurityStatusView(isConnected: true)
}


//MARK:  PremiumUpsellView.swift

struct PremiumUpsellView: View {
    let action: () -> Void // Action for the crown button in header

    var body: some View {
        HStack {
            Image(systemName: "crown.fill")
                .font(.title2)
                .foregroundColor(.yellow)
                .padding(8)
                .background(Color.yellow.opacity(0.2))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("Upgrade to Premium")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                Text("Get faster speeds and more servers")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                 action() // Call action to open premium screen
            } label: {
                 Text("PRO")
                     .font(.caption.weight(.bold))
                     .foregroundColor(.white)
                     .padding(.horizontal, 10)
                     .padding(.vertical, 5)
                     .background(LinearGradient(colors:[.skyblue,.accentPurple],
                                                startPoint: .leading,
                                                endPoint: .trailing)) // Or your premium color
                     .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground)) // Card background
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 5, y: 3)
    }
}



//MARK:  ConnectedServerView

struct ConnectedServerView: View {
    let server: ConnectedServerInfo // Pass the connected server data

    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: server.flagImageName)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                .frame(width: 36, height: 25) // Adjust size
                .clipShape(RoundedRectangle(cornerRadius: 4))

            VStack(alignment: .leading, spacing: 2) {
                Text(server.country)
                    .font(.headline.weight(.medium))
                    .foregroundColor(.primary)
                Text(server.cityAndIP)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
//
//            HStack(spacing: 4) {
//                 Image(systemName: "wifi", variableValue: Double(max(0, 100 - server.pingMillis)) / 100.0)
//                 Text("\(server.pingMillis)ms")
//            }
            .font(.caption.weight(.medium))
            .foregroundColor(server.pingColor)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 5, y: 3)
    }
}

