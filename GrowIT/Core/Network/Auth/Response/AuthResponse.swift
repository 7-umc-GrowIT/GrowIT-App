//
//  AuthResponse.swift
//  GrowIT
//
//  Created by 이수현 on 1/26/25.
//

import Foundation

struct VerifyResponse: Decodable {
    let message: String
}

struct LoginResponse: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: Tokens?
}

struct SignUpResponse: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: Tokens
}

struct Tokens: Codable {
    let accessToken: String
    let refreshToken: String
}

struct SocialLoginResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: SocialLoginResult
}

struct SocialLoginResult: Codable {
    let signupRequired: Bool
    let loginResponseDTO: LoginResponseDTO
    let oauthUserInfo: OauthUserInfo?
}

struct LoginResponseDTO: Codable {
    let tokens: Tokens?
    let loginMethod: String
}

struct OauthUserInfo: Codable {
    let socialId: String
    let email: String
    let name: String
    let provider: String
}

// 카카오 또는 애플 회원가입 전용 응답 구조체
struct SocialSignUpResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: Tokens
}


struct AuthResult: Codable {
    let accessToken: String
    let refreshToken: String
}

struct EmailVerifyResponse: Decodable {
    let email: String
    let message: String
    let code: String
    let expiration: String
}

struct SignOutResponse: Decodable {
    let name: String
    let message: String
}

struct ReissueResponse: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: AccessTokenData
}

struct AccessTokenData: Codable {
    let accessToken: String
}

struct postLogoutResponseDTO: Codable { }
