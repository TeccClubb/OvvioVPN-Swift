import SwiftUI

struct UserConsentView: View {
    @AppStorage("hasAcceptedConsentOvvio") private var hasAcceptedConsent = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {

                // App shield icon
                Image(systemName: "shield.checkerboard")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)
                    .padding(.bottom, 10)

                // Title
                Text("Before You Continue")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)

                // Subtitle / Description
                VStack(spacing: 8) {
                    Text("To use OvvioVPN, you must review and accept the Terms of Service and Privacy Policy.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("We value your privacy and never store logs of your activity.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                // Accept Button
                Button(action: {
                    hasAcceptedConsent = true
                }) {
                    Text("Accept & Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white.opacity(0.15))
                        .background(.ultraThinMaterial)
                        .cornerRadius(14)
                }
                .padding(.horizontal)

                // Links row
                HStack(spacing: 25) {
                    Button("Terms of Service") {}
                        .foregroundColor(.white.opacity(0.9))
                        .font(.system(size: 14))

                    Button("Privacy Policy") {}
                        .foregroundColor(.white.opacity(0.9))
                        .font(.system(size: 14))
                }
                .padding(.bottom, 40)
            }
            .padding(.top, 80)
        }
    }
}

#Preview {
    UserConsentView()
}
