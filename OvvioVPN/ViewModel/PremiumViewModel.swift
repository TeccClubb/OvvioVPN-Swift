import SwiftUI
import Combine
import Alamofire

// MARK: - Billing Cycle Toggle
enum BillingCycle: String, CaseIterable {
    case monthly, yearly
}

// MARK: - Premium ViewModel
@MainActor
class PremiumViewModel: ObservableObject {
    
    @Published var selectedCycle: BillingCycle = .yearly
    @Published var selectedPlanID: Int?
    
    @Published var isLoading = false
    @Published var alertDetails: CustomAlertDetails? = nil
    
    @Published private var allPlans: [Plan] = []
    
    private let storeKitManager = StoreKitManager()
    
    var plansToShow: [Plan] {
        allPlans.filter { plan in
            selectedCycle == .yearly ? plan.invoiceInterval == "year" : plan.invoiceInterval != "year"
        }
    }
    
    init() {
        fetchPlans()
    }
    
    // MARK: - Select Plan
    func selectPlan(_ plan: Plan) {
        selectedPlanID = plan.id
        let planCycle: BillingCycle = (plan.invoiceInterval == "year") ? .yearly : .monthly
        if selectedCycle != planCycle {
            withAnimation { selectedCycle = planCycle }
        }
        print("Selected plan: \(plan.name)")
    }
    
    // MARK: - Start Purchase / Trial
    func startPremiumTrial() {
        guard let selectedPlanID = selectedPlanID,
              let plan = allPlans.first(where: { $0.id == selectedPlanID }) else {
            print("No plan selected")
            return
        }
        
        guard let product = storeKitManager.products.first(where: { $0.id == plan.appstoreProductID }) else {
            print("StoreKit product not loaded for \(plan.appstoreProductID)")
            return
        }
        
        Task {
            do {
                try? await storeKitManager.purchase(product)
                print("✅ Purchase successful: \(product.displayName)")
                
                // Notify backend with user token
//                if let token = UserDefaults.standard.string(forKey: "userToken") {
//                    APIManager.shared.recordPurchase(planID: plan.id, token: token)
//                }
                
            } catch {
                print("❌ Purchase failed: \(error.localizedDescription)")
                alertDetails = CustomAlertDetails(
                    type: .error,
                    title: "Purchase Failed",
                    message: error.localizedDescription
                )
            }
        }
    }
    
    // MARK: - Fetch Plans
    func fetchPlans() {
        isLoading = true
        alertDetails = nil
        
        APIManager.shared.request(.getPlans) { (result: Result<PlanResponse, AFError>, _) in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    if response.status {
                        self.allPlans = response.plans
                        self.selectedPlanID = self.allPlans.first(where: { $0.isBestDeal })?.id
                            ?? self.allPlans.first(where: { $0.invoiceInterval == "year" })?.id
                            ?? self.allPlans.first?.id
                        
                        if let defaultPlan = self.allPlans.first(where: { $0.id == self.selectedPlanID }) {
                            self.selectedCycle = (defaultPlan.invoiceInterval == "year") ? .yearly : .monthly
                        }
                        
                        // Fetch StoreKit products after plans load
                        Task { await self.fetchStoreKitProducts() }
                        
                    } else {
                        self.alertDetails = CustomAlertDetails(
                            type: .error,
                            title: "Error",
                            message: "Failed to load plans."
                        )
                    }
                case .failure(let error):
                    self.alertDetails = CustomAlertDetails(
                        type: .error,
                        title: "Network Error",
                        message: error.localizedDescription
                    )
                }
            }
        }
    }
    
    // MARK: - StoreKit Products
    func fetchStoreKitProducts() async {
        let productIDs = allPlans.compactMap { $0.appstoreProductID } // removes nils
        await storeKitManager.fetchProduts(identifiers: productIDs)
        print("StoreKit products loaded: \(storeKitManager.products.map { $0.id })")
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() {
        Task {
            await storeKitManager.restorePurchase()
            print("Restored subscriptions: \(storeKitManager.purchasedSubscriptions.map { $0.displayName })")
        }
    }
}
