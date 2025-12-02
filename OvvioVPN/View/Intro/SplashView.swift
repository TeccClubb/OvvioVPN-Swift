import SwiftUI

struct Splash: View {
    // State for progress animation
    @State private var progress: CGFloat = 0.0
    @State private var isComplete: Bool = false

    // To check if onboarding is done later
    @AppStorage("hasCompletedOnboardingOvvio") private var hasCompletedOnboarding = false // Use a unique key
    @EnvironmentObject var appStateManager: AppStateManager

    // Define animation duration
    private let animationDuration: TimeInterval = 2.5
    private let postAnimationDelay: TimeInterval = 0.3
    var body: some View {
        Group { // Use Group to switch between views
                    // Check if splash animation is finished
                    if isComplete {
                        // Animation finished, now check onboarding and authentication
                        if !hasCompletedOnboarding {
                            // Show onboarding if it hasn't been completed
                            OnboardingView() // This view must set hasCompletedOnboarding = true
                                .transition(.opacity)
                        } else if !appStateManager.isAuthenticated {
                            // --- Auth Flow Start ---
                            // Onboarding is done, BUT user is NOT authenticated.
                            // Wrap the start of the auth flow in ONE NavigationStack.
                            NavigationStack {
                                LoginView() // Start with Login screen
                            }
                            // Pass EnvironmentObjects needed by Login/Signup down here
                            // .environmentObject(appStateManager) // Already available from parent
                            .transition(.opacity)
                            // --- End Auth Flow ---
                        } else {
                            // Onboarding is done AND user IS authenticated, show Main App
                            MainAppView() // Your main app view with tab bar
                                .transition(.opacity)
                        }
                    } else {
                        // Show the splash screen content while animation runs
                        splashContent
                    }
                }
            .onAppear {
                startProgress()
            }
        }

    // Extracted Splash UI into a computed property
    private var splashContent: some View {
        ZStack {
            // Background (optional, white is default)
            Color.white.ignoresSafeArea()

            VStack(spacing: 20) { // Add spacing between elements
                Spacer() // Pushes logo and text towards center

                // Logo
                Image(.logo) // Ensure '.logo' asset exists
                    .resizable()
                    .scaledToFit() // Use scaledToFit to avoid distortion
                    .frame(width: 200, height: 200)

                // App Name
                HStack(spacing: 0) { // Use spacing 0 if letters should touch
                    Text("Ovvio")
                        .font(.PoppinsBold(size: 35)) // Ensure this font exists
                        .foregroundStyle(.skyblue)    // Ensure this color exists

                    Text("VPN")
                        .font(.PoppinsBold(size: 35))
                        .foregroundStyle(.accentPurple) // Ensure this color exists
                }

                Spacer() // Pushes progress bar towards bottom

                // --- Progress Bar ---
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.gray.opacity(0.2)) // Light gray background
                        .frame(height: 8)

                    // Progress fill
                    Capsule()
                        .fill(Color.skyblue) // Use your skyblue color
                        // Animate width based on progress
                        .frame(width: progress * 300, height: 8) // Assuming max width 300
                }
                .frame(width: 300) // Set width for the ZStack
                 // Padding from the bottom edge
                // --- End Progress Bar ---
                Text("Initializing secure connection")
                    .foregroundStyle(.gray)
                    .padding(.bottom,50)
            }
        }
    }

    // Function to handle the animation and completion
    private func startProgress() {
        // Animate the progress value from 0 to 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Short delay
            withAnimation(.easeInOut(duration: animationDuration)) {
                progress = 1.0
            }
        }

        // Set completion after animation finishes + delay
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + postAnimationDelay) {
            isComplete = true
        }
    }
}



#Preview {
    Splash()
}
