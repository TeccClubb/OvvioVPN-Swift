//
//  UserModel.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 31/10/2025.
//
import Foundation

// MARK: - Welcome
struct Welcome: Codable {
    let status: Bool
    let user: User
}

// MARK: - User
struct User: Codable {
    let id: Int
    let appAccountToken, name, slug, email: String
    let emailVerifiedAt: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case appAccountToken = "app_account_token"
        case name, slug, email
        case emailVerifiedAt = "email_verified_at"
        case createdAt = "created_at"
    }
}
