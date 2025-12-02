//
//  LoginViewModel.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 27/10/2025.
//

import Foundation
import SwiftUI
import Combine
import Alamofire

enum LoginFocusableField: Hashable {
    case email
    case password
    case username
}

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var rememberMe = false
    @Published var errorMessage: String? = nil
    @Published var isLoading = false
    @Published var alertDetails: CustomAlertDetails? = nil // ✅ To trigger custom alert

    var appStateManager: AppStateManager?
    
    init(appStateManager: AppStateManager? = nil) {
        self.appStateManager = appStateManager
    }
    
    var isEmailValid: Bool {
        email.contains("@") && email.contains(".")
    }

    var isLoginFormValid: Bool {
        !email.isEmpty && !password.isEmpty && isEmailValid
    }
    
    func login() {
        guard isLoginFormValid else {
            alertDetails = CustomAlertDetails(
                type: .error,
                title: "Invalid Input",
                message: "Please enter a valid email and password."
            )
            return
        }

        isLoading = true
        errorMessage = nil

        fetchIP { ipAddress in
            guard let ip = ipAddress else {
                self.isLoading = false
                self.alertDetails = CustomAlertDetails(
                    type: .error,
                    title: "Network Error",
                    message: "Unable to fetch IP address."
                )
                return
            }

            print("🌐 IP Address fetched: \(ip)")

            let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
            let deviceName = UIDevice.current.name
            let platform = "ios"
            let deviceType = "mobile"

            APIManager.shared.request(
                .login(email: self.email,
                       password: self.password,
                       deviceId: deviceId,
                       deviceName: deviceName,
                       platform: platform,
                       deviceType: deviceType,
                       IpAdress: ip)
            ) { (result: Result<LoginResponse, AFError>, _) in
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch result {
                    case .success(let response):
                        if response.status == true {
                            print("✅ Login Success: \(response.user?.email ?? "")")
                            UserDefaults.standard.setValue(response.user?.email, forKey: "Useremail")
                            UserDefaults.standard.setValue(response.user?.appAccountToken, forKey: "UserAppToken")
                            UserDefaults.standard.setValue(response.accessToken, forKey: "authToken")
                            UserDefaults.standard.setValue(response.user?.name, forKey: "userName")
                        
                            
                            self.alertDetails = CustomAlertDetails(
                                type: .success,
                                title: "Login Successful",
                                message: "Welcome back \(response.user?.name ?? "")!",
                                buttonTitle: "OK",
                                onDismiss: {
                                    // ✅ Trigger navigation when alert dismissed
                                    DispatchQueue.main.async {
                                        self.appStateManager?.login()
                                    }
                                }
                            )
                        }
                        else {
                            self.alertDetails = CustomAlertDetails(
                                type: .error,
                                title: "Login Failed",
                                message: response.message ?? "Invalid credentials. Please try again."
                            )
                        }

                    case .failure(let error):
                        self.alertDetails = CustomAlertDetails(
                            type: .error,
                            title: "Server Error",
                            message: error.localizedDescription
                        )
                    }
                }
            }
        }
    }

    // ✅ Fetch IP Function
    func fetchIP(completion: @escaping (String?) -> Void) {
        let urlString = "https://ipinfo.io/json?token=e5a357763a1f67"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let info = try JSONDecoder().decode(IPInfo.self, from: data)
                    DispatchQueue.main.async { completion(info.ip) }
                } catch {
                    print("❌ Failed to decode IP info:", error)
                    DispatchQueue.main.async { completion(nil) }
                }
            } else {
                print("❌ Failed to fetch IP:", error?.localizedDescription ?? "Unknown error")
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }

    func forgotPassword() {
        print("Forgot Password tapped")
    }

    func loginWithGoogle() {
        print("Login with Google")
    }

    func loginWithApple() {
        print("Login with Apple")
    }

    func navigateToCreateAccount() {
        print("Navigate to Create Account")
    }
}
