//
//  FeedBackViewModel.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 27/10/2025.
//

import SwiftUI
import Combine // Needed for @Published

// Reuse the focus enum if applicable, or define a specific one
// enum LoginFocusableField: Hashable { case email }

class ForgotPassViewModel: ObservableObject {

    // MARK: - Published State Properties
    @Published var email = ""
    @Published var isLoading = false
    @Published var feedbackMessage: String? = nil // For success/error messages
    @Published var showSuccessMessage = false // Controls showing the success message UI

    // Simple email validation (reuse or enhance)
    var isEmailValid: Bool {
        email.contains("@") && email.contains(".")
    }

    // Computed property to enable/disable submit button
    var isSubmitEnabled: Bool {
        !email.isEmpty && isEmailValid && !isLoading
    }

    // MARK: - Public Methods (Actions)

    /// Initiates the password reset request.
    func submitRequest() {
        guard isEmailValid else {
            feedbackMessage = "Please enter a valid email address."
            showSuccessMessage = false // Ensure success message is hidden on error
            return
        }

        isLoading = true
        feedbackMessage = nil // Clear previous messages
        showSuccessMessage = false
        print("Submitting password reset request for: \(email)")

        // --- Replace with your actual password reset logic ---
        // Example: AuthService.shared.sendPasswordReset(email: email) { error in
        //     DispatchQueue.main.async {
        //         self.isLoading = false
        //         if let error = error {
        //             self.feedbackMessage = "Error: \(error.localizedDescription)"
        //             self.showSuccessMessage = false
        //         } else {
        //             self.feedbackMessage = "Password reset email sent successfully!"
        //             self.showSuccessMessage = true // Show success state
        //         }
        //     }
        // }
        // --- End Replace ---

        // --- Simulation ---
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isLoading = false
            // Simulate success
            self.feedbackMessage = "If an account exists for \(self.email), a password reset link has been sent."
            self.showSuccessMessage = true
            print("Password reset email sent (Simulation)")
        }
        // --- End Simulation ---
    }

    /// Placeholder for navigation logic (usually handled by the View using dismiss or NavigationPath).
    /// This might not be strictly needed in the ViewModel if the View handles dismissal.
    func goBackToLogin() {
        print("Triggering navigation back to Login")
        // In the View, you would typically call dismiss()
    }
}
