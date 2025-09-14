//
//  AuthRequest.swift
//  GrowIT
//
//  Created by 이수현 on 1/26/25.
//

import Foundation
import Moya

// 이메일 회원가입 API
struct AuthSignUpRequestDTO: Codable {
    let isVerified: Bool        // 이메일 인증 여부
    let email: String           // 사용자 이메일
    let name: String            // 사용자 이름
    let password: String        // 사용자 비밀번호
    let userTerms: [UserTermDTO] // 약관 동의 리스트
}

// 소셜 간편 가입 API
struct AuthSignUpSocialRequestDTO: Codable {
    let userTerms: [UserTermDTO]
}

struct UserTermDTO: Codable {
    let termId: Int
    let agreed: Bool

    enum CodingKeys: String, CodingKey {
        case termId
        case agreed
    }
}

// 토큰 재발급 API
struct AuthReissueRequestDTO: Codable {
    let refreshToken: String
}

// 이메일 로그인 API
struct AuthLoginRequestDTO: Codable {
    let email: String
    let password: String
}

// 소셜 로그인 API
struct AuthLoginSocialRequestDTO: Codable {
    let code: String
    let name: String
}

// 인증번호 검증 API
struct AuthEmailVerifyRequestDTO: Codable {
    let email: String // 이메일 주소
    let authCode: String // 인증번호
}

// 인증 이메일 발송 API
struct AuthEmailSendReqeustDTO: Codable {
    let email: String
}
