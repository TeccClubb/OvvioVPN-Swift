//
//  SignUpViewModel.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 27/10/2025.
//

import SwiftUI
import Combine
import Alamofire

class SignupViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var signedUp = false
    @Published var createdUser: SignUpUser? = nil
    @Published var alertDetails: CustomAlertDetails?   // 👈 Centralized alert

    var appStateManager: AppStateManager?

    init(appStateManager: AppStateManager? = nil) {
        self.appStateManager = appStateManager
    }

    // MARK: - Validation
    var isUsernameValid: Bool { username.count >= 3 }
    var isEmailValid: Bool { email.contains("@") && email.contains(".") }
    var isPasswordValid: Bool { password.count >= 6 }
    var isSignupFormValid: Bool {
        isUsernameValid && isEmailValid && isPasswordValid
    }

    // MARK: - Signup Function
    
    
    func signup() {
        guard isSignupFormValid else {
            alertDetails = CustomAlertDetails(
                type: .error,
                title: "Invalid Input",
                message: "Please fill all fields correctly. Username must be 3+ chars, password 6+ chars."
            )
            return
        }

        isLoading = true
        print("Attempting signup with Username: \(username), Email: \(email)")

        APIManager.shared.request(.signup(name: username, email: email, password: password)) {
            (result: Result<SignUpUserResponse, AFError>, data) in

            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .success(let response):
                    if response.status ?? false {
                        self.createdUser = response.user
                        self.clearForm()

                        // ✅ Only navigate after user taps OK
                        self.alertDetails = CustomAlertDetails(
                            type: .success,
                            title: "Signup Successful",
                            message: response.message ?? "Your account has been created successfully.",
                            onDismiss: {
                                self.signedUp = true   // ✅ move navigation trigger here
                            }
                        )
                    } else {
                        let errorMessage = response.message ??
                                           response.errors?.first ??
                                           "Something went wrong. Please try again."

                        self.alertDetails = CustomAlertDetails(
                            type: .error,
                            title: "Signup Failed",
                            message: errorMessage
                        )
                    }

                case .failure(let error):
                    // 🌐 Network-level error
                    let errorMessage: String
                    if let data = data,
                       let decodedError = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        errorMessage = decodedError.message ?? "Server error occurred."
                    } else {
                        errorMessage = error.localizedDescription
                    }

                    self.alertDetails = CustomAlertDetails(
                        type: .error,
                        title: "Network Error",
                        message: errorMessage
                    )
                }
            }
        }
    }


    // MARK: - Helpers
    private func clearForm() {
        username = ""
        email = ""
        password = ""
    }

    func signupWithGoogle() {
        print("Signup with Google")
    }

    func signupWithApple() {
        print("Signup with Apple")
    }

    func navigateToLogin() {
        print("Navigate to Login")
    }
}

// MARK: - Error Response Model
struct ErrorResponse: Codable {
    let message: String?
    let errors: [String]?
}
