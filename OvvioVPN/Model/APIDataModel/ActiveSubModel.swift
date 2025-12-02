//
//  ActiveSubModel.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 03/11/2025.
//

import Foundation

// MARK: - Welcome
struct SubResponse: Codable {
    let status: Bool
    let message: String
    let subscription: Subscription?
    let isOnTrial: Bool?
    let provider: String?

    enum CodingKeys: String, CodingKey {
        case status, message, subscription
        case isOnTrial = "is_on_trial"
        case provider
    }
}

// MARK: - Subscription
struct Subscription: Codable {
    let id: Int
    let plan: ActivePlan
    let startsAt, endsAt, trialEndsAt, graceEndsAt: String?
    let amountPaid, currency, status: String
    let isRecurring: Bool
    let provider: String
    let cancelledBy, cancelledReason: String?
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, plan
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case trialEndsAt = "trial_ends_at"
        case graceEndsAt = "grace_ends_at"
        case amountPaid = "amount_paid"
        case currency, status
        case isRecurring = "is_recurring"
        case provider
        case cancelledBy = "cancelled_by"
        case cancelledReason = "cancelled_reason"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Plan
struct ActivePlan: Codable {
    let id: Int
    let name, slug, description, originalPrice: String
    let discountPrice: String
    let invoicePeriod: Int
    let invoiceInterval: String
    let trialPeriod: Int
    let trialInterval, paddlePriceID, appstoreProductID: String
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
}
