//
//  AuthResponse.swift
//  GrowIT
//
//  Created by 이수현 on 1/26/25.
//

import Foundation
// 이메일 회원가입 API
struct AuthSignUpResponseDTO: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: EmailResult?
}

struct EmailResult: Codable {
    let tokens: Tokens
    let loginMethod: String
}

// 소셜 간편 가입 API
struct AuthSignUpSocialResponseDTO: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: SocialSignUpResponseDTO
}

struct SocialSignUpResponseDTO: Codable {
    let tokens: Tokens
    let loginMethod: String
}

struct Tokens: Codable {
    let accessToken: String
    let refreshToken: String
}

// 토큰 재발급 API
struct AuthReissueResponseDTO: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: AccessTokenData
}

struct AccessTokenData: Codable {
    let accessToken: String
}

// 이메일 로그인 API
struct AuthLoginResponseDTO: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: EmailResult?
}

// 소셜 로그인 API
struct AuthLoginSocialResponsetDTO: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: SocialLoginResult
}

struct SocialLoginResult: Codable {
    let signupRequired: Bool
    let loginResponseDTO: LoginResponseDTO?
    let oauthUserInfo: OauthUserInfo?
}

struct LoginResponseDTO: Codable {
    let tokens: Tokens?
    let loginMethod: String?
}

struct OauthUserInfo: Codable {
    let socialId: String
    let email: String
    let name: String
    let provider: String
}

// 인증번호 검증 API
struct AuthEmailVerifyResponseDTO: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
}

// 인증 이메일 발송 API
struct AuthEmailSendResponseDTO: Codable {
    let expiration: String
}

// 로그아웃 API
struct postLogoutResponseDTO: Codable { }
