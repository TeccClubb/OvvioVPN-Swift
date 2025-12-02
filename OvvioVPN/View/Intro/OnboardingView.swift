import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboardingOvvio") private var hasCompletedOnboarding = false
    @State private var selectedPage = 0

    let pages: [OnboardingPageData] = [
        OnboardingPageData(
            imageName: "logo",
            titlePart1: "Welcome To",
            titlePart2: "Ovvio VPN",
            description: "Your gateway to the digital kingdom. Fast, secure, and borderless — OvvioVPN rules your world."
        ),
        OnboardingPageData(
            imageName: "onBoarding-2",
            titlePart1: "Stay Completely",
            titlePart2: "Hidden",
            description: "Your data, your rules — encrypted, invisible, and protected beyond limits."
        ),
        OnboardingPageData(
            imageName: "onBoarding-3",
            titlePart1: "Beyond All",
            titlePart2: "Borders",
            description: "Unlock blazing speed with uncompromised security — crafted for those who demand the best."
        )
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip Button
                HStack {
                    Spacer()
                    Button("Skip") {
                        finishOnboarding()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
                }
                .padding()

                // Onboarding Pages
                TabView(selection: $selectedPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(data: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                Spacer()

                // Full Width Button
                Button {
                    handleNext()
                } label: {
                    HStack {
                        Spacer()
                        Text(isLastPage() ? "Get Started" : "Next")
                            .font(.headline.weight(.semibold))
                        Image(systemName: "arrow.right")
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.skyblue, .accentPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 16)

                // Page Indicators Below Button
                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { index in
                        Circle()
                            .fill(index == selectedPage ? Color.accentPurple : Color(.systemGray4))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 40)
            }
            .animation(.easeInOut, value: selectedPage)
        }
    }

    private func isLastPage() -> Bool {
        selectedPage == pages.count - 1
    }

    private func finishOnboarding() {
        hasCompletedOnboarding = true
    }

    private func handleNext() {
        if isLastPage() {
            finishOnboarding()
        } else {
            withAnimation(.easeInOut) {
                selectedPage += 1
            }
        }
    }
}

#Preview {
    OnboardingView()
}
