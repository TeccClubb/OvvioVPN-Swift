////
////  PremiumComp.swift
////  OvvioVPN
////
////  Created by Saad Suleman on 28/10/2025.
////
//
import Foundation
import SwiftUI
////MARK:PremiumHeader
//struct PremiumHeaderView: View {
//    @Environment(\.dismiss) var dismiss
//    let title: String
//    let action : () -> Void
//    
//    var body: some View {
//        HStack {
//            Button(action: action) { // <-- 2. Use the action here
//                            Image(systemName: "chevron.left")
//                                .font(.title2.weight(.medium))
//                                .foregroundColor(.primary)
//                                .padding(8)
//                                .clipShape(Circle())
//                        }
//
//            Spacer()
//            Text(title)
//                .font(.PoppinsBold(size: 20)) // Your custom font
//                .foregroundColor(.primary) // Your semantic color
//            Spacer()
//
//            // Invisible placeholder to balance layout
//            Circle().fill(Color.clear).frame(width: 40, height: 40)
//        }
//        .padding(.horizontal)
//        .padding(.top, 5)
//        .padding(.bottom, 10)
//    }
//}
//
////MARK:PlanToggleView
//
//struct PlanToggleView: View {
//    @Binding var selectedCycle: BillingCycle
//    @Namespace private var animationNamespace // For smooth animation
//
//    var body: some View {
//        HStack(spacing: 0) {
//            // Yearly Button
//            Button {
//                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
//                    selectedCycle = .yearly
//                }
//            } label: {
//                Text("Yearly")
//                    .font(.subheadline.weight(.semibold))
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 10)
//                    .foregroundColor(selectedCycle == .yearly ? .white : Color(.label))
//                    .background {
//                        if selectedCycle == .yearly {
//                            Capsule()
//                                .fill(LinearGradient(colors: [.skyblue, .accentPurple], startPoint: .leading, endPoint: .trailing))
//                                .matchedGeometryEffect(id: "selection", in: animationNamespace) // Animate background
//                        }
//                    }
//            }
//            .buttonStyle(PlainButtonStyle())
//
//            // Monthly Button
//            Button {
//                 withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
//                    selectedCycle = .monthly
//                 }
//            } label: {
//                Text("Monthly")
//                    .font(.subheadline.weight(.semibold))
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 10)
//                    .foregroundColor(selectedCycle == .monthly ? .white : Color(.label))
//                    .background {
//                        if selectedCycle == .monthly {
//                            Capsule()
//                                .fill(LinearGradient(colors: [.skyblue, .accentPurple], startPoint: .leading, endPoint: .trailing))
//                                .matchedGeometryEffect(id: "selection", in: animationNamespace) // Animate background
//                        }
//                    }
//            }
//            .buttonStyle(PlainButtonStyle())
//        }
//        .padding(5) // Padding inside the main container
//        .background(Color(.secondarySystemGroupedBackground))
//        .clipShape(Capsule())
//        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
//    }
//}
//
////MARK: PlanFeatureRow
//
//struct PlanFeatureRow: View {
//    let feature: String
//    
//    var body: some View {
//        HStack(spacing: 10) {
//            Image(systemName: "checkmark.circle.fill")
//                .font(.subheadline)
//                .foregroundColor(.blue) // Use your gradient start color
//            Text(feature)
//                .font(.subheadline)
//                .foregroundColor(Color(.label)) // Adaptive
//        }
//    }
//}
//
////MARK: PlanCardView
//
//struct PlanCardView: View {
//    let plan: Plan
//    let isSelected: Bool
//    let action: () -> Void // Action to select this plan
//
//    private let cornerRadius: CGFloat = 20
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            // MARK: - Header (Title, Price, Tag)
//            VStack(alignment: .leading, spacing: 8) {
//                Text(plan.name)
//                    .font(.headline.weight(.semibold))
//                    .foregroundColor(.primary)
//
//                HStack(alignment: .firstTextBaseline, spacing: 4) {
//                    Text(plan.discountPrice)
//                        .font(.system(size: 36, weight: .bold))
//                        .foregroundColor(.primary)
//                    Text(plan.invoiceInterval)
//                        .font(.subheadline.weight(.medium))
//                        .foregroundColor(.secondary)
//                        .padding(.bottom, 5)
//                }
////
//                // Check if the originalPrice string is not empty
////                if !plan.originalPrice.isEmpty {
////                    Text(plan.originalPrice)
////                        .font(.caption)
////                        .strikethrough(true, color: .secondary)
////                        .foregroundColor(.secondary)
////                }
////
////                Text(plan.originalPrice)
////                    .font(.footnote.weight(.medium))
////                    .foregroundColor(.blue) // Blue color as in screenshot
//            }
//
//            // MARK: - Feature List
//
//            // MARK: - Upgrade Button (Only on unselected card)
//            if !isSelected {
//                Button(action: action) { // Use action to select this card
//                    HStack(spacing: 8) {
//                        Image(systemName: "crown.fill")
//                        Text("Upgrade to Premium")
//                    }
//                    .font(.headline.weight(.semibold))
//                    .foregroundColor(.primary)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 14)
//                    .background(Color(.systemGray5)) // Light gray background
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                }
//                .buttonStyle(PlainButtonStyle())
//            }
//
//        } // End Main VStack
//        .padding(20)
//        .frame(maxWidth: .infinity)
//        .background(Color(.secondarySystemGroupedBackground))
//        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
//        .overlay( // Border overlay
//            ZStack(alignment: .topTrailing) {
//                // Conditional Border
//                if isSelected {
//                    // Use the animated gradient border
//                    AnimatedGradientBorder(cornerRadius: cornerRadius, lineWidth: 3)
//                } else {
//                    RoundedRectangle(cornerRadius: cornerRadius)
//                        .stroke(Color(.systemGray4), lineWidth: 1)
//                }
//
////                // Discount Tag
////                if let discount = plan.discountPrice {
////                    Text(discount)
////                        .font(.caption2.weight(.bold))
////                        .foregroundColor(.white) // White text
////                        .padding(.horizontal, 10)
////                        .padding(.vertical, 5)
////                        .background(Color.yellow) // Yellow tag
////                        // Custom shape to match screenshot
////                        .clipShape(RoundedRectangle(cornerRadius: 20))
////                        .offset(x: 1, y: -12) // Position tag
////                }
//            }
//        )
//        .onTapGesture {
//            action() // Make the whole card tappable
//        }
//    }
//}

struct PremiumHeaderView: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Button(action: action) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(10)
            }
            
            Spacer()
            Text(title)
                .font(.PoppinsSemiBold(size: 20))
                .foregroundColor(.primary)
            Spacer()
            
            // Invisible circle to balance
            Circle().fill(Color.clear).frame(width: 40)
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }
}

struct PlanToggleView: View {
    @Binding var selectedCycle: BillingCycle
    @Namespace private var ns
    
    var body: some View {
        HStack(spacing: 0) {
            
            // Yearly
            toggleButton(title: "Yearly", cycle: .yearly)
            
            // Monthly
            toggleButton(title: "Monthly", cycle: .monthly)
        }
        .padding(5)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
    }
    
    @ViewBuilder
    func toggleButton(title: String, cycle: BillingCycle) -> some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedCycle = cycle
            }
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundColor(
                    selectedCycle == cycle ? .white : .primary
                )
                .background(
                    ZStack {
                        if selectedCycle == cycle {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.skyblue, .accentPurple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .matchedGeometryEffect(id: "toggle", in: ns)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }
}

struct PremiumPlanCard: View {
    let plan: Plan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Price
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(plan.discountPrice)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                
                Text(plan.invoiceInterval)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.9))
                    .padding(.bottom, 5)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                feature("Unlimited high-speed servers")
                feature("Access to 70+ countries")
                feature("No ads, no logs")
                feature("24/7 secure connection")
                feature("Priority customer support")
            }
            
            Button(action: action) {
                HStack {
                    Image(systemName: "crown.fill")
                    Text("Upgrade to Premium")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.skyblue, .accentPurple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
        )
    }
    
    func feature(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
                .font(.system(size: 13))
            Text(text)
                .foregroundColor(.white)
                .font(.system(size: 14))
        }
    }
}

struct StickyButtonOverlay: View {
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            
            Button(action: action) {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("Start Premium Trial")
                    }
                }
            }
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [.skyblue, .accentPurple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 24)
            
            Text("7-day free trial • Cancel anytime")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("30-day money-back guarantee")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            
        }
        .padding(.top, 10)
        .background(.ultraThinMaterial)
    }
}
