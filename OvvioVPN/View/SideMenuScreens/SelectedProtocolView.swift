//
//  SelectedProtocolView.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 28/10/2025.
//

// SelectProtocolView.swift
import SwiftUI

struct SelectProtocolView: View {
    @StateObject private var viewModel = SelectProtocolViewModel()
    @Environment(\.dismiss) var dismiss // For back button

    var body: some View {
        VStack(spacing: 0) { // Main VStack

            // --- Custom Header ---
            SelectProtocolHeaderView { // Use dedicated header
                dismiss() // Back action
            }

            // --- Scrollable List ---
            ScrollView {
                VStack(alignment: .leading, spacing: 20) { // Spacing between title and cards

                    Text("Available Protocols")
                        .font(.PoppinsBold(size: 20))
                        .foregroundColor(.primary) // Use semantic color
                        .padding(.horizontal) // Indent title

                    // List of Protocol Cards
                    ForEach(viewModel.availableProtocol) { protocolInfo in
                        ProtocolCardView(
                            protocolInfo: protocolInfo,
                            selectedProtocolId: $viewModel.selectedProtocol
                        )
                    }

                } // End List VStack
                .padding() // Padding around the list section

            } // End ScrollView

        } // End Main VStack
        .background(Color(.systemBackground).ignoresSafeArea()) // Use adaptive background
        .navigationBarHidden(true) // Hide default bar
    }
}

// --- Custom Header Component ---
struct SelectProtocolHeaderView: View {
    let backAction: () -> Void

    var body: some View {
        HStack {
            Button(action: backAction) {
                Image(systemName: "chevron.left")
                    .font(.title2.weight(.medium))
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(Color(.systemGray5).opacity(0.6))
                    .clipShape(Circle())
            }

            Spacer()
            Text("Select Protocol")
                .font(.PoppinsSemiBold(size: 20)) // Adjust font
                .foregroundColor(.primary)
            Spacer()

            // Invisible placeholder to balance layout
            Circle().fill(Color.clear).frame(width: 40, height: 40)
        }
        .padding(.horizontal)
        .padding(.top, 5)
        .padding(.bottom, 15) // Space below header
    }
}

// --- Keep Placeholders & Previews ---



#Preview {
    // Wrap in NavStack for preview if needed
    NavigationStack {
        SelectProtocolView()
    }
}
