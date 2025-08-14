//
//  TokenManager.swift
//  GrowIT
//
//  Created by 강희정 on 2/1/25.
//

import Foundation

final class TokenManager {
    static let shared = TokenManager()
    
    private init() {}

    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"

    /// Access Token 저장
    func saveTokens(accessToken: String, refreshToken: String) {
        UserDefaults.standard.set(accessToken, forKey: accessTokenKey)
        UserDefaults.standard.set(refreshToken, forKey: refreshTokenKey)
        // print("🔒 AccessToken 저장됨: \(accessToken)")
        // print("🔒 RefreshToken 저장됨: \(refreshToken)")
    }
    
    /// Access Token만 저장하는 메서드 추가
    func saveAccessToken(_ accessToken: String) {
        UserDefaults.standard.set(accessToken, forKey: accessTokenKey)
        // print("🔒 AccessToken 저장됨: \(accessToken)")
    }

    func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: accessTokenKey)
    }

    func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: refreshTokenKey)
    }

    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
    }
}
