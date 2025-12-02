//
//  AccountViewModel.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 31/10/2025.
//

import Foundation
import Combine
import Alamofire

class AccountViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var subscription : Subscription?
    
    // --- 1. CHANGE THIS ---
    // This will be nil until the View passes it in
    private var appStateManager: AppStateManager?

    // --- 2. UPDATE INIT ---
    // It no longer takes any parameters
    init() {
        // We will call getUser() and getSubscription() from the View's .task
        // so that appStateManager is guaranteed to be set first.
    }
    
    // --- 3. ADD THIS FUNCTION ---
    /// This function allows the View to pass in the dependency
    /// after the ViewModel has been created.
    func setAppStateManager(_ manager: AppStateManager) {
        self.appStateManager = manager
    }
    
    func getUser() {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            self.errorMessage = "No token found."
            return
        }
        
        isLoading = true
        
        APIManager.shared.request(.getUser(token: token)) { (result: Result<Welcome, AFError>, data: Data?) in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.status {
                        self.user = response.user
                        print("✅ User fetched successfully: \(response.user.name)")
                    } else {
                        self.errorMessage = "Failed to load user data."
                        print("❌ API returned failure.")
                    }
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("❌ API Error:", error)
                }
            }
        }
    }
    
    func getSubscription(){
        
        guard  let token = UserDefaults.standard.string(forKey: "authToken") else{
            self.errorMessage = "Token Not Found"
            return
        }
        
        // We can set isLoading true for both calls
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        APIManager.shared.request(.getActivePurchase(token:token)){ (result : Result <SubResponse,AFError>, data : Data?) in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result{
                case.success(let subscriptionResponse): // Renamed for clarity
                    if subscriptionResponse.status {
                        self.subscription = subscriptionResponse.subscription
                        
                        // --- 4. THIS LOGIC IS PERFECT ---
                        // If status is true AND we have a subscription object, user is premium
                        let isPremium = subscriptionResponse.subscription != nil
                        self.appStateManager?.updatePremiumStatus(to: isPremium)
                        
                        if !isPremium {
                            self.errorMessage = "No Active Plan Found"
                        }
                        // ---
                        
                    }else{
                        self.errorMessage = "No Active Plan Found"
                        self.appStateManager?.updatePremiumStatus(to: false)
                    }
                case.failure(let error) :
                    self.errorMessage = error.localizedDescription
                    print("API Error :", error)
                    self.appStateManager?.updatePremiumStatus(to: false)
                }
            }
            
        }
    }
}
