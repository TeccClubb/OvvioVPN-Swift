
import SwiftUI

// MARK: - Model
// (Models are simple data structures, no changes needed)

/// Model for server information
struct ServerInfo: Identifiable, Equatable {
    let id = UUID()
    let flag: String
    let country: String
    let details: String
    let ping: Int
    var isFavourite: Bool
}

/// Enum for Quick Action selection
enum QuickAction {
    case fastest
    case random
}

/// Enum for Server Tab selection
enum ServerTab: String, CaseIterable {
    case allServers = "All Servers"
    case premium = "Premium"
    case favourites = "Favourites"
}


import Foundation

// MARK: - Welcome
struct ServerResponse: Codable {
    let status: Bool
    let servers: [WelcomeServer]
}

// MARK: - WelcomeServer
struct WelcomeServer: Codable, Identifiable {
    let id: Int
    let image: String
    let name: String
    let platforms: Platforms
    let type: TypeEnum
    let status: Bool
    let createdAt: String
    let subServers: [SubServer]

    enum CodingKeys: String, CodingKey {
        case id, image, name, platforms, type, status
        case createdAt = "created_at"
        case subServers = "sub_servers"
    }
}

// MARK: - Platforms
struct Platforms: Codable {
    let android, ios, macos, windows: Bool
}

// MARK: - SubServer
struct SubServer: Codable {
    let id, serverID: Int
    let name: String
    let status: Bool
    let vpsGroup: VpsGroup

    enum CodingKeys: String, CodingKey {
        case id
        case serverID = "server_id"
        case name, status
        case vpsGroup = "vps_group"
    }
}

// MARK: - VpsGroup
struct VpsGroup: Codable {
    let id: Int
    let name: String
    let servers: [VpsGroupServer]
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, servers
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - VpsGroupServer
struct VpsGroupServer: Codable {
    let id: Int
    let name, ipAddress, domain: String
    let port: Int
    let status: Bool
    let cpuUsage, ramUsage, diskUsage: Int
    let totalMbitPerS: Double
    let healthScore: Int
    let bandwidth: Int?   // ✅ changed to optional
    let bandwidthLimitPerSecond, ramLimit, cpuLimit, diskLimit: Int?
    let role: Role
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case ipAddress = "ip_address"
        case domain, port, status
        case cpuUsage = "cpu_usage"
        case ramUsage = "ram_usage"
        case diskUsage = "disk_usage"
        case totalMbitPerS = "total_mbit_per_s"
        case healthScore = "health_score"
        case bandwidth
        case bandwidthLimitPerSecond = "bandwidth_limit_per_second"
        case ramLimit = "ram_limit"
        case cpuLimit = "cpu_limit"
        case diskLimit = "disk_limit"
        case role
        case createdAt = "created_at"
    }
}


enum Role: String, Codable {
    case inactive = "inactive"
    case primary = "primary"
    case secondary = "secondary"
}


enum TypeEnum: String, Codable {
    case free = "free"
    case premium = "premium"
}
