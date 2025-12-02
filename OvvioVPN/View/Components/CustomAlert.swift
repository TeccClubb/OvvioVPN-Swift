//
//  CustomAlert.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 29/10/2025.
//

import Foundation
import SwiftUI

// MARK: - 1. Alert Data Model

/// Defines the style of the alert (success or error)
enum CustomAlertType {
    case success
    case error

    var iconName: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .success:
            return .green
        case .error:
            return .red
        }
    }
}

/// The data needed to show a specific alert
struct CustomAlertDetails: Identifiable {
    let id = UUID()
    let type: CustomAlertType
    let title: String
    let message: String
    var buttonTitle: String = "OK"
    var onDismiss : (() -> Void)? = nil
}

// MARK: - 2. The Alert's UI

/// The actual pop-up card view
struct CustomAlertView: View {
    let details: CustomAlertDetails
    let dismissAction: () -> Void // Action to close the alert

    // Use your app's theme colors
    private let buttonGradient = LinearGradient(
        colors: [.skyblue, .accentPurple],
        startPoint: .leading, endPoint: .trailing
    )

    var body: some View {
        VStack(spacing: 15) {
            
            // --- Icon ---
            Image(systemName: details.type.iconName)
                .font(.system(size: 40))
                .foregroundColor(details.type.iconColor)
                .padding(.top, 10) // Add space above icon

            // --- Text ---
            VStack(spacing: 5) {
                Text(details.title)
                    .font(.headline.weight(.bold))
                    .foregroundColor(Color(.label)) // Adaptive
                
                Text(details.message)
                    .font(.body)
                    .foregroundColor(Color(.secondaryLabel)) // Adaptive
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            // --- Button ---
            Button(
                action: {
                    dismissAction()
                    details.onDismiss?()
                }
            ) {
                Text(details.buttonTitle)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(buttonGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20) // Internal padding
        .background(.regularMaterial) // Blur background
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10) // Soft shadow
        .padding(30) // Padding from screen edges
    }
}

// MARK: - 3. The View Modifier & Extension

/// A ViewModifier to apply the alert as an overlay
struct CustomAlertModifier: ViewModifier {
    // Binding to the optional alert details
    @Binding var alertDetails: CustomAlertDetails?
    
    // We use this to animate the presence of the alert
    private var isPresented: Bool {
        alertDetails != nil
    }

    func body(content: Content) -> some View {
        ZStack {
            // The main content of the view
            content

            // --- The Alert Overlay ---
            ZStack { // ZStack for the whole screen
                if isPresented {
                    // Dim/Blur background
                    Color.black.opacity(0.3) // Dimming effect
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            // Optional: Tap background to dismiss
                            // withAnimation { alertDetails = nil }
                        }

                    // The Alert Card
                    CustomAlertView(details: alertDetails!) {
                        // Dismiss action for the button
                        withAnimation {
                            alertDetails = nil
                        }
                    }
                    .transition(.scale(scale: 0.8).combined(with: .opacity)) // Pop-in/out
                }
            }
            // Animate the appearance/disappearance of the ZStack
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isPresented)
        }
    }
}

// 4. Easy-to-use extension on View
extension View {
    /// Presents a beautiful, custom alert that matches the app theme.
    ///
    /// - Parameter alertDetails: A @Binding to an optional `CustomAlertDetails` struct.
    ///   When this binding becomes non-nil, the alert appears.
    ///   When the alert is dismissed, it is set back to nil.
    func customAlert(alertDetails: Binding<CustomAlertDetails?>) -> some View {
        self.modifier(CustomAlertModifier(alertDetails: alertDetails))
    }
}
