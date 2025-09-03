//
//  TokenManager.swift
//  GrowIT
//
//  Created by 강희정 on 2/1/25.
//

import Security
import Foundation

final class TokenManager {
    static let shared = TokenManager()
    private init() {}

    private let service = "com.growit.auth"

    // MARK: - Save
    func saveTokens(accessToken: String, refreshToken: String) {
        saveKeychain(key: "accessToken", value: accessToken)
        saveKeychain(key: "refreshToken", value: refreshToken)
    }

    func saveAccessToken(_ accessToken: String) {
        saveKeychain(key: "accessToken", value: accessToken)
    }

    // MARK: - Get
    func getAccessToken() -> String? {
        return loadKeychain(key: "accessToken")
    }

    func getRefreshToken() -> String? {
        return loadKeychain(key: "refreshToken")
    }

    // MARK: - Clear
    func clearTokens() {
        deleteKeychain(key: "accessToken")
        deleteKeychain(key: "refreshToken")
    }

    // MARK: - Keychain Helpers
    private func saveKeychain(key: String, value: String) {
        let data = value.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary) // 기존 값 제거
        SecItemAdd(query as CFDictionary, nil)
    }

    private func loadKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &dataTypeRef) == noErr,
           let data = dataTypeRef as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        }
        return nil
    }

    private func deleteKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
