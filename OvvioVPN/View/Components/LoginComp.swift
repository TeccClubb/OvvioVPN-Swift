//
//  LoginComp.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 27/10/2025.
//

import Foundation
import SwiftUI



struct LoginInputView: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var iconName: String
    var isEmailField: Bool = false // Still useful for keyboard type
    var isValid: Bool = true // For checkmark

    @State private var showPassword: Bool = false
    var focusedField: FocusState<LoginFocusableField?>.Binding
    var fieldIdentifier: LoginFocusableField

    // Check if THIS field instance is focused
    private var isFocused: Bool {
        focusedField.wrappedValue == fieldIdentifier
    }

    // Colors
    private let focusedBorderColor = Color.skyblue // Your blue accent color
    private let defaultBackgroundColor = Color(.secondarySystemGroupedBackground) // Adaptive light gray
    private let iconColor = Color.gray.opacity(0.8)
    private let checkmarkColor = Color.skyblue

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .frame(width: 20)

            Group { // Keep .focused() modifiers here
                if isSecure {
                    if showPassword {
                        TextField(placeholder, text: $text)
                            .foregroundColor(Color(.label))
                            .focused(focusedField, equals: fieldIdentifier)
                    } else {
                        SecureField(placeholder, text: $text)
                            .foregroundColor(Color(.label))
                            .focused(focusedField, equals: fieldIdentifier)
                    }
                } else {
                    TextField(placeholder, text: $text)
                        .foregroundColor(Color(.label))
                        .keyboardType(isEmailField ? .emailAddress : .default)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused(focusedField, equals: fieldIdentifier)
                }
            }

            // Show/Hide Password or Checkmark
            if isSecure {
                Button { showPassword.toggle() } label: {
                    Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                        .foregroundColor(iconColor)
                }
            } else if isEmailField && isValid && !text.isEmpty {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(checkmarkColor)
            }

        } // End HStack
        .padding(.horizontal, 15)
        .padding(.vertical, 14)
        .background(defaultBackgroundColor) // Always use the default background
        .clipShape(RoundedRectangle(cornerRadius: 12))
        // --- CORRECTED BORDER LOGIC ---
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                // Show blue border ONLY if focused, otherwise clear/no border
                .stroke(isFocused ? focusedBorderColor : Color.clear, lineWidth: 1.5)
        )
        // --- END CORRECTION ---
        .shadow(color: .black.opacity(isFocused ? 0.1 : 0.05), radius: isFocused ? 5 : 3, y: isFocused ? 3 : 2)
        // Animate border and shadow changes smoothly
        .animation(.easeOut(duration: 0.2), value: isFocused)
    }
}





struct SocialLoginButton: View {
    enum Provider {
        case google, apple
    }
    let provider: Provider
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            // --- Conditional Image Loading ---
            Group { // Use Group to apply common modifiers
                if provider == .google {
                    Image("google") // Use your custom asset named "google"
                        .resizable()
                } else {
                    Image(systemName: "apple.logo") // Use the SF Symbol for Apple
                        .resizable() // Still make it resizable
                        .foregroundColor(Color(.label)) // Use adaptive color for SF Symbol
                }
            }
            .scaledToFit()
            .frame(width: 24, height: 24) // Adjust icon size
            // --- End Conditional Image ---
            .frame(maxWidth: .infinity) // Center icon
            .padding(.vertical, 14)
            .background(Color(.secondarySystemGroupedBackground)) // Adaptive background
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 3, y: 2) // Subtle shadow
        }
        .buttonStyle(PlainButtonStyle())
    }
}

