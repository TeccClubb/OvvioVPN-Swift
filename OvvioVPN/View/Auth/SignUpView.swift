import SwiftUI

struct SignupView: View {
    @StateObject var viewModel = SignupViewModel()
    @FocusState private var focusedField: LoginFocusableField?
    @EnvironmentObject var appStateManager: AppStateManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Header
                    VStack(spacing: 5) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)

                        HStack(spacing: 0) {
                            Text("Ovvio")
                                .font(.PoppinsBold(size: 30))
                                .foregroundColor(.skyblue)
                            Text("VPN")
                                .font(.PoppinsBold(size: 30))
                                .foregroundColor(.accentPurple)
                        }

                        Text("Rule Your Connection")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 30)

                    // MARK: - Fields
                    VStack(spacing: 15) {
                        LoginInputView(
                            placeholder: "Username",
                            text: $viewModel.username,
                            iconName: "person.fill",
                            isEmailField: false,
                            isValid: viewModel.isUsernameValid,
                            focusedField: $focusedField,
                            fieldIdentifier: .username
                        )
                        .autocapitalization(.none)

                        LoginInputView(
                            placeholder: "Email address",
                            text: $viewModel.email,
                            iconName: "envelope.fill",
                            isEmailField: true,
                            isValid: viewModel.isEmailValid,
                            focusedField: $focusedField,
                            fieldIdentifier: .email
                        )

                        LoginInputView(
                            placeholder: "Password",
                            text: $viewModel.password,
                            isSecure: true,
                            iconName: "lock.fill",
                            isValid: viewModel.isPasswordValid,
                            focusedField: $focusedField,
                            fieldIdentifier: .password
                        )
                    }

                    // MARK: - Sign Up Button
                    Button {
                        viewModel.signup()
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            }
                            Text("Sign Up")
                                .font(.headline.weight(.bold))
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [.skyblue, .accentPurple],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(viewModel.isLoading || !viewModel.isSignupFormValid)
                    .opacity(viewModel.isSignupFormValid ? 1.0 : 0.6)
                    .animation(.easeInOut, value: viewModel.isSignupFormValid || viewModel.isLoading)

                    // MARK: - OR Separator
                    HStack {
                        Rectangle().fill(.gray.opacity(0.2)).frame(height: 1)
                        Text("OR")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 5)
                        Rectangle().fill(.gray.opacity(0.2)).frame(height: 1)
                    }
                    .padding(.vertical, 15)

                    // MARK: - Social Sign Ups
                    HStack(spacing: 15) {
                        SocialLoginButton(provider: .google, action: viewModel.signupWithGoogle)
                        SocialLoginButton(provider: .apple, action: viewModel.signupWithApple)
                    }

                    // MARK: - Already have an account
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .foregroundColor(.secondary)
                        Button("Login") { dismiss() }
                            .foregroundColor(.skyblue)
                    }
                    .font(.subheadline)
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 30)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarBackButtonHidden(true)
        .onTapGesture { focusedField = nil }
        .onAppear {
            viewModel.appStateManager = appStateManager
        }
        .onChange(of: viewModel.signedUp) { signedUp in
            if signedUp {
                dismiss()
            }
        }
        // ✅ Add your custom alert here
        .customAlert(alertDetails: $viewModel.alertDetails)
    }
}

#Preview {
    SignupView()
        .environmentObject(AppStateManager())
}
