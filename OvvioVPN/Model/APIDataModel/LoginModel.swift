import Foundation

// MARK: - LoginResponse
struct LoginResponse: Codable {
    let status: Bool?
    let message: String?
    let user: UserModel?
    let accessToken: String?
    let tokenType: String?

    enum CodingKeys: String, CodingKey {
        case status, message, user
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

// MARK: - UserModel
struct UserModel: Codable {
    let id: Int?
    let appAccountToken: String?
    let name: String?
    let slug: String?
    let email: String?
    let emailVerifiedAt: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case appAccountToken = "app_account_token"
        case name, slug, email
        case emailVerifiedAt = "email_verified_at"
        case createdAt = "created_at"
    }
}
