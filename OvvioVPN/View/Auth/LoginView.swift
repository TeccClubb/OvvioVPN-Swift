// LoginView.swift
import SwiftUI

struct LoginView: View {
    // 1. Create ViewModel instance
    @StateObject private var viewModel = LoginViewModel()
    // 2. Focus State
    @FocusState private var focusedField: LoginFocusableField?
    // 3. Get AppStateManager if needed for the login action
    @EnvironmentObject var appStateManager: AppStateManager // Assuming AppStateManager exists

    var body: some View {
        ZStack {
            // Optional: Background color/image
            Color(.systemBackground).ignoresSafeArea() // Adaptive background

            ScrollView { // Make content scrollable
                VStack(spacing: 20) { // Main content stack

                    // --- Header ---
                    VStack(spacing: 5) {
                        Image("logo") // Your main logo asset name
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100) // Adjust size

                        HStack(spacing: 0) {
                            Text("Ovvio")
                                .font(.PoppinsBold(size: 30)) // Your custom font
                                .foregroundColor(.skyblue) // Your color
                            Text("VPN")
                                .font(.PoppinsBold(size: 30))
                                .foregroundColor(.accentPurple) // Your color
                        }

                        Text("Rule Your Connection")
                            .font(.footnote) // Adjust font
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 30)


                    // --- Input Fields ---
                    VStack(spacing: 15) {
                        LoginInputView(
                            placeholder: "Email address",
                            text: $viewModel.email,
                            iconName: "envelope.fill",
                            isEmailField: true, // Apply special styling
                            isValid: viewModel.isEmailValid, // Pass validation state
                            focusedField: $focusedField,
                            fieldIdentifier: .email
                        )

                        LoginInputView(
                            placeholder: "Password",
                            text: $viewModel.password,
                            isSecure: true,
                            iconName: "lock.fill",
                            focusedField: $focusedField,
                            fieldIdentifier: .password
                        )
                    }


                    // --- Remember Me & Forgot Password ---
                    HStack {
//                        Button {
//                            viewModel.rememberMe.toggle()
//                        } label: {
//                            HStack(spacing: 8) {
//                                Image(systemName: viewModel.rememberMe ? "checkmark.square.fill" : "square")
//                                    .foregroundColor(viewModel.rememberMe ? .skyblue : .secondary) // Use accent color
//                                Text("Remember me")
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                        .buttonStyle(PlainButtonStyle())

                        Spacer()

                        NavigationLink("Forgot password"){
                            ForgotPassView()
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.skyblue) // Use accent color
                    }


                    // --- Login Button ---
                    Button {
                        // In real app, call viewModel.login() which then calls appStateManager
                        viewModel.login()
                        // Example Direct Call (if not using ViewModel login logic yet):
                        // if viewModel.isLoginFormValid { appStateManager.login() }
                    } label: {
                        HStack {
                            Spacer()
                            Button(action: {
                                viewModel.login()
                            }, label: {
                                Text("Login")
                                    .font(.headline.weight(.bold))
                            })
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient( // Button Gradient
                                colors: [.skyblue, .accentPurple], // Your gradient colors
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(viewModel.isLoading || !viewModel.isLoginFormValid) // Disable when loading or invalid
                    .opacity(viewModel.isLoginFormValid ? 1.0 : 0.6) // Dim if invalid
                    .animation(.easeInOut, value: viewModel.isLoginFormValid)
                    .animation(.easeInOut, value: viewModel.isLoading)


                    // --- Error Message ---
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }


                    // --- OR Separator ---
                    HStack {
                        Rectangle().fill(.gray.opacity(0.2)).frame(height: 1)
                        Text("OR").font(.caption).foregroundColor(.secondary).padding(.horizontal, 5)
                        Rectangle().fill(.gray.opacity(0.2)).frame(height: 1)
                    }
                    .padding(.vertical, 15)


                    // --- Social Logins ---
                    HStack(spacing: 15) {
                        SocialLoginButton(provider: .google, action: viewModel.loginWithGoogle)
                        SocialLoginButton(provider: .apple, action: viewModel.loginWithApple)
                    }


                    // --- Create Account Link ---
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        NavigationLink("Create Account")
                        {
                            SignupView()
                        }
                        .foregroundColor(.skyblue) // Use accent color
                    }
                    .font(.subheadline)
                    .padding(.top, 30) // More space above this link
                    .padding(.bottom, 20) // Padding at the very bottom


                } // End Main Content VStack
                .padding(.horizontal, 30) // Main horizontal padding

            } // End ScrollView
            
            if viewModel.isLoading{
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.6)
                    .progressViewStyle(CircularProgressViewStyle())
            }
        } // End ZStack
        // Hide keyboard when tapping outside text fields
        .onTapGesture {
            focusedField = nil
        }
        .onAppear{
            viewModel.appStateManager = appStateManager
        }
        .customAlert(alertDetails: $viewModel.alertDetails)
    }
}


#Preview {
    LoginView()
        .environmentObject(AppStateManager()) // Provide for preview
}
