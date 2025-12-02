//
//  FeedbackModel.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 03/11/2025.
//

import Foundation
import SwiftUI
import Combine
import Alamofire // <-- ADDED

// MARK: - API Response Model
// --- UPDATED ---
// This now perfectly matches the JSON response you provided.
struct FeedbackResponse: Codable {
    let status: Bool
    let message: String
    let feedback: FeedbackDetail
}

struct FeedbackDetail: Codable {
    let subject: String
    let email: String
    let message: String
    let updatedAt: String
    let createdAt: String
    let id: Int

    enum CodingKeys: String, CodingKey {
        case subject, email, message, id
        case updatedAt = "updated_at"
        case createdAt = "created_at"
    }
}
