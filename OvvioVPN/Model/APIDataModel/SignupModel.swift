//
//  SignupModel.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 29/10/2025.
//

import Foundation
// MARK: - Main Response Model
struct SignUpUserResponse: Codable {
    let status: Bool?
    let message: String?
    let user: SignUpUser?
    let errors: [String]?   
}

struct SignUpUser: Codable {
    let id: Int
    let name: String
    let slug: String
    let email: String
    let emailVerifiedAt: String?
    let role: String?
    let appAccountToken: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug, email, role
        case emailVerifiedAt = "email_verified_at"
        case appAccountToken = "app_account_token"
        case createdAt = "created_at"
    }
}
