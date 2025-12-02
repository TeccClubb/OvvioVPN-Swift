import Foundation

// MARK: - PlanResponse
struct PlanResponse: Codable {
    let status: Bool
    let plans: [Plan]
}

// MARK: - Plan
// Added Identifiable & Equatable for SwiftUI
struct Plan: Codable, Identifiable, Equatable {
    let id: Int
    let name, slug, description, originalPrice: String
    let discountPrice: String
    let invoicePeriod: Int
    let invoiceInterval: String
    let trialPeriod: Int
    let trialInterval, paddlePriceID: String
    let appstoreProductID: String? // <- optional now
    let isActive, isBestDeal: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, slug, description
        case originalPrice = "original_price"
        case discountPrice = "discount_price"
        case invoicePeriod = "invoice_period"
        case invoiceInterval = "invoice_interval"
        case trialPeriod = "trial_period"
        case trialInterval = "trial_interval"
        case paddlePriceID = "paddle_price_id"
        case appstoreProductID = "appstore_product_id"
        case isActive = "is_active"
        case isBestDeal = "is_best_deal"
        case createdAt = "created_at"
    }

    static func == (lhs: Plan, rhs: Plan) -> Bool {
        lhs.id == rhs.id
    }
    
    var ovvioProductID: String? {
        guard let appID = appstoreProductID else { return nil }
        switch appID {
        case "safepro_399_1m": return "ovvio_399_1m"
        case "safepro_1399_6m": return "ovvio_1399_6m"
        case "safepro_2499_1y": return "ovvio_2499_1y"
        default: return appID
        }
    }
}

