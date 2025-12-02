//
//  ForgotPassView.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 27/10/2025.
//

import SwiftUI

struct ForgotPassView: View {
    // 1. Create ViewModel instance
    @StateObject private var viewModel = ForgotPassViewModel()
    // 2. Focus State (using LoginFocusableField.email)
    @FocusState private var focusedField: LoginFocusableField?
    // 3. Environment for dismissing the view
    @Environment(\.dismiss) var dismiss

    var body: some View {
        // Use NavigationStack if needed for a title bar
        // NavigationStack {
            VStack(spacing: 10) { // Main VStack

                // --- Header (Logo, Name, Tagline) ---
                VStack(spacing: 5) {
                    Image("logo") // Your asset name
                        .resizable().scaledToFit().frame(width: 100, height: 100)
                    HStack(spacing: 0) {
                        Text("Ovvio").font(.PoppinsBold(size: 30)).foregroundColor(.skyblue)
                        Text("VPN").font(.PoppinsBold(size: 30)).foregroundColor(.accentPurple)
                    }
                    Text("Rule Your Connection").font(.footnote).foregroundColor(.secondary)
                }
                .padding(.bottom, 30) // Space below header


                // --- Email Input ---
                LoginInputView( // Reuse your input view
                    placeholder: "Email address",
                    text: $viewModel.email,
                    iconName: "envelope.fill",
                    isEmailField: true,
                    isValid: viewModel.isEmailValid,
                    focusedField: $focusedField,
                    fieldIdentifier: .email // Assuming .email exists in LoginFocusableField
                )

                // --- Feedback Message ---
                if let message = viewModel.feedbackMessage {
                    Text(message)
                        .font(.caption)
                        // Use green for success, red for error
                        .foregroundColor(viewModel.showSuccessMessage ? .green : .red)
                        .padding(.top, 5)
                }

                // --- Submit Button ---
                Button {
                    viewModel.submitRequest()
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView().tint(.white).padding(.trailing, 5)
                        }
                        Text("Submit")
                            .font(.headline.weight(.bold))
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient( // Match signup button style
                            colors: [.skyblue, .accentPurple],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!viewModel.isSubmitEnabled) // Disable based on ViewModel state
                .opacity(viewModel.isSubmitEnabled ? 1.0 : 0.6)
                .animation(.easeInOut, value: viewModel.isSubmitEnabled)
                .animation(.easeInOut, value: viewModel.isLoading)


                // --- Back to Login Button ---
                Button("Back to Login") {
                    // Call dismiss() to go back in the NavigationStack
                    dismiss()
                    // viewModel.goBackToLogin() // Or call ViewModel if it needs extra logic
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(.skyblue) // Use accent color
                .padding(.top, 10) // Space above back button

                Spacer()

            } // End Main VStack
            .padding(.horizontal, 30) // Main horizontal padding
            // Bottom padding
            // Hide keyboard on tap outside
            .onTapGesture { focusedField = nil }
            // Optional: Add Navigation Title if using NavigationStack
            // .navigationTitle("Reset Password")
            // .navigationBarTitleDisplayMode(.inline)
             .navigationBarBackButtonHidden(true) // If using custom back button

        // } // End NavigationStack (if used)
    }
}

// --- Keep Placeholders & Previews ---

#Preview {
    // Wrap in NavigationStack for preview context if needed
    NavigationStack {
        ForgotPassView()
    }
}

