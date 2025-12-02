//
//  StoreKitManager.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 10/11/2025.
//

import Foundation
import StoreKit

@MainActor
class StoreKitManager: ObservableObject {
    @Published var products : [Product] = []
    @Published var purchasedSubscriptions : [Product] = []
    @Published var isLoading : Bool = false
    @Published var isPurchasing : Bool = false
    private var updates : Task<Void ,Never>? = nil
    
    init(){
        updates = listenForTransaction()
    }
    deinit{
        updates?.cancel()
    }
    
    
    //MARK: - Load Products
    
    func fetchProduts(identifiers : [String]) async {
        do{
            isLoading = true
            print("Fetching Prodcuts with IDs \(identifiers)")
            products = try await Product.products(for: identifiers)
            print("✅ Loaded products: \(products.map { $0.id })")
            isLoading = false
        }catch{
            print("Failed to ftch products \(error)")
            isLoading = false
        }
    }
    //MARK: - Purchase
    func purchase(_ product : Product) async throws  {
        await MainActor.run{self.isPurchasing = true}
        defer {Task {@MainActor in self.isPurchasing = false}}
//        let keychain = KeychainService()
//        
//        guard let tokenString = keychain.getPasswordString(for: "UserAppToken")else{return}
        guard let tokenString  = UserDefaults.standard.string(forKey: "UserAppToken"),
        let tokenUUID = UUID(uuidString: tokenString) else{
            print("NO app token Found")
            return
        }
        
        let result = try await product.purchase(options: [.appAccountToken(tokenUUID)])
        
        switch result {
        case .success(let verification):
            switch verification{
            case .unverified :
                print("Transaction unverified")
            case .verified(let transcation) :
                await updatePurchasedProducts()
                await transcation.finish()
            }
        case .userCancelled:
            print("User Cancelled Purchase")
        case .pending:
            print("Purchase Pending")
        @unknown default :
            break
        }
    }
    
      //MARK: Restore Purchase /Listen
    
    private func listenForTransaction() -> Task<Void,Never> {
        Task.detached{
            for await result in Transaction.updates{
                if case .verified(let transaction) = result {
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                }
            }
        }
    }
    
    func restorePurchase() async {
        do{
            for await result in Transaction.currentEntitlements{
                if case .verified(let transaction) = result {
                    print("Restored :\(transaction.productID)")
                }
            }
            await updatePurchasedProducts()
        }catch{
            print("Restore Failed :\(error)")
        }
    }
    
    //MARK: - Update state
    
    private func updatePurchasedProducts () async {
        var newSubs : [Product] = []
        for await result in Transaction.currentEntitlements{
            if case .verified(let transaction) = result {
                if let product = products.first(where: {$0.id == transaction.productID}){
                    newSubs.append(product)
                }
            }
        }
        await MainActor.run {
            self.purchasedSubscriptions = newSubs
        }
    }
    
}
