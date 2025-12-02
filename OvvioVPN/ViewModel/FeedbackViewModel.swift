//
//  FeedbackViewModel.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 28/10/2025.
//

import SwiftUI
import Combine
import Alamofire

class FeedbackViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var rating: Int = 0
    @Published var feedbackText: String = ""
    @Published var selectedTopics: Set<String> = []
    
    @Published var isLoading: Bool = false
    @Published var alertDetails: CustomAlertDetails? = nil // <-- CHANGED
    @Published var shouldDismiss: Bool = false           // <-- ADDED
    
    // --- REMOVED ---
    // @Published var errorMessage: String?
    // @Published var didSubmitSuccessfully: Bool = false
    
    // MARK: - Data
    let topics = ["Easy To Use", "Fast Connection", "Connection Drop", "More Server Needed"]
    
    // MARK: - Computed Properties
    var isFormValid: Bool {
        return (rating > 0 && !selectedTopics.isEmpty) || !feedbackText.isEmpty
    }
    
    // MARK: - Actions
    
    /// Toggles a topic in the selection set
    func toggleTopic(_ topic: String) {
        if selectedTopics.contains(topic) {
            selectedTopics.remove(topic)
        } else {
            selectedTopics.insert(topic)
        }
    }
    
    /// Submits the feedback to the API
    func submitFeedback() {
        guard isFormValid else {
            print("Form is not valid")
            return
        }
        
        // 1. Get token and email
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            // --- UPDATED ---
            self.alertDetails = CustomAlertDetails(
                type: .error,
                title: "Error",
                message: "You are not logged in."
            )
            return
        }
        guard let email = UserDefaults.standard.string(forKey: "Useremail") else {
            // --- UPDATED ---
            self.alertDetails = CustomAlertDetails(
                type: .error,
                title: "Error",
                message: "Could not find user email."
            )
            return
        }
        
        // 2. Set loading state
        isLoading = true
        alertDetails = nil // Clear old alerts
        
        // 3. Construct the message string
        let subject = "OvvioVPN Feedback"
        let topicsString = selectedTopics.joined(separator: ", ")
        let message = """
        Rating: \(rating) stars
        Topics: \(topicsString)
        
        Comment:
        \(feedbackText)
        """
        
        // 4. Make API Call
        APIManager.shared.request(.feedback(email: email, subject: subject, message: message, token: token)) { (result: Result<FeedbackResponse, AFError>, data: Data?) in
            
            // 5. Handle response on main thread
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.status {
                        print("✅ Feedback submitted successfully!")
                        // --- UPDATED ---
                        // Show success alert, and set 'shouldDismiss'
                        // to true when the alert's button is tapped.
                        self.alertDetails = CustomAlertDetails(
                            type: .success,
                            title: "Feedback Sent",
                            message: response.message,
                            buttonTitle: "OK",
                            onDismiss: {
                                self.shouldDismiss = true
                            }
                        )
                        
                    } else {
                        // --- UPDATED ---
                        self.alertDetails = CustomAlertDetails(
                            type: .error,
                            title: "Error",
                            message: response.message
                        )
                        print("❌ API returned failure.")
                    }
                    
                case .failure(let error):
                    // --- UPDATED ---
                    self.alertDetails = CustomAlertDetails(
                        type: .error,
                        title: "Server Error",
                        message: error.localizedDescription
                    )
                    print("❌ API Error:", error)
                }
            }
        }
    }
}
