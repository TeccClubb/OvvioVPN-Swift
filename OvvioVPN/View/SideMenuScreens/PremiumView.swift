import SwiftUI

struct PremiumView: View {
    @StateObject private var viewModel = PremiumViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    
                    PremiumHeaderView(title: "Premium") {
                        dismiss()
                    }
                    .padding(.top)
                    
                    // Crown Icon
                    Image(systemName: "crown.fill")
                        .font(.system(size: 52))
                        .foregroundColor(Color.yellow)
                        .padding(.top, 8)
                    
                    // Title
                    Text("Unlock Premium VPN")
                        .font(.PoppinsBold(size: 22))
                        .foregroundColor(.primary)
                        .padding(.top, 6)
                    
                    // Subtitle
                    Text("Experience ultimate security and freedom")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    // Toggle
                    PlanToggleView(selectedCycle: $viewModel.selectedCycle)
                        .padding(.top, 4)
                        .padding(.horizontal, 40)
                    
                    // Premium Cards
                    VStack(spacing: 20) {
                        ForEach(viewModel.plansToShow) { plan in
                            PremiumPlanCard(
                                plan: plan,
                                isSelected: viewModel.selectedPlanID == plan.id,
                                action: { viewModel.selectPlan(plan) }
                            )
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 130)
                }
            }
            
            // Sticky CTA
            StickyButtonOverlay(
                isLoading: viewModel.isLoading,
                action: viewModel.startPremiumTrial
            )
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

#Preview{
    PremiumView()
}
