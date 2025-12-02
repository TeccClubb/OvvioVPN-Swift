import SwiftUI

struct FeedbackView: View {
    @StateObject private var viewModel = FeedbackViewModel()
    @Environment(\.dismiss) var dismiss
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) { // Main VStack
            // --- Header ---
            FeedbackHeaderView(title: "Feedback") {
                dismiss() // Call dismiss action
            }

            // --- Scrollable Form ---
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {

                    // --- Star Rating Card ---
                    VStack(alignment: .leading, spacing: 15) {
                        Text("How would you rate your experience ?")
                            .font(.PoppinsMedium(size: 18))
                        
                        StarRatingView(rating: $viewModel.rating)
                            .frame(maxWidth: .infinity, alignment: .center) // Center the stars
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)


                    // --- Topics Section ---
                    VStack(alignment: .leading, spacing: 10) {
                        Text("What can we rate?") // Title had a typo in screenshot
                            .font(.PoppinsMedium(size: 18))
                            .padding(.bottom, 5)

                        // Loop through topics
                        ForEach(viewModel.topics, id: \.self) { topic in
                            RateTopicRowView(
                                title: topic,
                                isSelected: viewModel.selectedTopics.contains(topic),
                                action: {
                                    viewModel.toggleTopic(topic) // Toggle selection in ViewModel
                                }
                            )
                            // Add dividers
                            if topic != viewModel.topics.last {
                                Divider()
                            }
                        }
                    }

                    // --- Text Editor Section ---
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tell us more (Optional)")
                            .font(.PoppinsMedium(size: 18))
                        ZStack(alignment: .topLeading) {
                            // Background with shadow
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemGroupedBackground))
                                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 4) // Subtle shadow
                                .frame(minHeight: 120)
                            
                            // TextEditor
                            TextEditor(text: $viewModel.feedbackText)
                                .padding(8)
                                .frame(minHeight: 120)
                                .background(Color.clear) // keep clear so shadow is visible
                                .focused($isTextFieldFocused)
                            
                            // Placeholder
                            if viewModel.feedbackText.isEmpty && !isTextFieldFocused {
                                Text("Share your thoughts, suggestions, or report and any issues")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .allowsHitTesting(false)
                            }
                        }

                        
                        
                    }

                    Spacer() // Pushes button down if content is short

                } // End Form VStack
                .padding()

            } // End ScrollView


            // --- Sticky Bottom Button ---
            Button(action: {
                viewModel.submitFeedback()
                // We no longer dismiss here, we wait for the .onChange
            }) {
                // --- UPDATED: Show loading indicator ---
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: "paperplane.fill")
                        Text("Share Feedback")
                    }
                }
            }
            .font(.headline.weight(.bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 25) // Added minHeight for ProgressView
            .padding(.vertical, 14)
            .background(
                LinearGradient( // Use gradient from login screen
                    colors: [.skyblue, .accentPurple], // Use your colors
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12)) // Rounded rect, not capsule
            .opacity(viewModel.isFormValid ? 1.0 : 0.6) // Dim if invalid
            .disabled(!viewModel.isFormValid || viewModel.isLoading) // Disable button
            .padding(.horizontal, 30)
            .padding(.bottom, 15)
            
        } // End Main VStack
        .background(Color(.systemBackground).ignoresSafeArea()) // Adaptive background
        .navigationBarHidden(true) // Hide default bar
        .onTapGesture { // Dismiss keyboard
            isTextFieldFocused = false
        }
        
        // --- REMOVED ---
        // .onChange(of: viewModel.didSubmitSuccessfully) { ... }
        // .alert("Error", ...) { ... }
        
        // --- ADDED: Handle Custom Alert ---
        .customAlert(alertDetails: $viewModel.alertDetails)
        
        // --- ADDED: Handle Dismissal After Alert ---
        .onChange(of: viewModel.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                dismiss() // Dismiss the view
            }
        }
    }
}


// --- Keep Placeholders & Previews ---

#Preview {
    // Wrap in NavigationStack for preview
    NavigationStack {
        FeedbackView()
    }
}
