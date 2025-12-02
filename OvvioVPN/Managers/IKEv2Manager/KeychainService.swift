//
//  KeychainService.swift
//  Goto-VPN
//
//  Created by Saad Suleman on 24/09/2025.
//

import Foundation
import Security

final class KeychainService {

    private let service: String

    init(service: String = "GShieldVPN") {
        self.service = service
    }

    // MARK: - Save Item
    func saveItem(k key: String, v value: String) {
        guard let valueData = value.data(using: .utf8) else {
            print("❌ Failed to encode value to Data")
            return
        }

        let query: [String: Any] = [
            kSecClass as String           : kSecClassGenericPassword,
            kSecAttrAccount as String     : key,
            kSecAttrService as String     : service,
            kSecValueData as String       : valueData,
            kSecAttrAccessible as String  : kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemDelete(query as CFDictionary)  // Remove if existing
        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            print("🔐 Keychain Save Success for key: \(key)")
        } else {
            print("❌ Keychain Save Failed: \(status)")
        }
    }

    // MARK: - Load Item as Data
    func loadItem(k key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String         : kSecClassGenericPassword,
            kSecAttrAccount as String   : key,
            kSecAttrService as String   : service,
            kSecMatchLimit as String    : kSecMatchLimitOne,
            kSecReturnData as String    : true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess {
            return result as? Data
        } else {
            print("❌ Keychain Load Failed for key: \(key) - Status: \(status)")
            return nil
        }
    }

    // MARK: - Get Persistent Ref for VPN Tunnel
    func getPasswordReference(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String             : kSecClassGenericPassword,
            kSecAttrAccount as String       : key,
            kSecAttrService as String       : service,
            kSecReturnPersistentRef as String: true,
            kSecMatchLimit as String        : kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess {
            return result as? Data
        } else {
            print("❌ Keychain Ref Fetch Failed for key: \(key) - Status: \(status)")
            return nil
        }
    }

    // MARK: - Delete Item
    func deleteItem(k key: String) {
        let query: [String: Any] = [
            kSecClass as String         : kSecClassGenericPassword,
            kSecAttrAccount as String   : key,
            kSecAttrService as String   : service
        ]
        let status = SecItemDelete(query as CFDictionary)
        print(status == errSecSuccess
              ? "🧹 Keychain Deleted Key: \(key)"
              : "⚠️ Keychain Delete Failed or Not Found: \(status)")
    }
}

// MARK: - Utility Accessors
extension KeychainService {
    func getPasswordString(for key: String) -> String? {
        guard let data = loadItem(k: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func getPassword(for key: String) -> Data? {
        return getPasswordReference(for: key) ?? loadItem(k: key)
    }
}
