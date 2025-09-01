//
//  AuthRequest.swift
//  GrowIT
//
//  Created by 이수현 on 1/26/25.
//

import Foundation
import Moya

// 인증번호 확인 API
struct EmailVerifyRequest: Codable {
    let email: String // 이메일 주소
    let authCode: String // 인증번호
}

struct EmailSignUpRequest: Codable {
    let isVerified: Bool        // 이메일 인증 여부
    let email: String           // 사용자 이메일
    let name: String            // 사용자 이름
    let password: String        // 사용자 비밀번호
    let userTerms: [UserTermDTO] // 약관 동의 리스트
}

// 카카오 또는 애플 로그인 요청
struct SocialLoginRequest: Codable {
    let code: String
    let name: String
}

struct SocialSignUpRequest: Codable {
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

struct ReissueTokenRequest: Codable {
    let refreshToken: String 
}

struct EmailLoginRequest: Codable {
    let email: String
    let password: String
}

struct SendEmailVerifyRequest: Codable {
    let email: String
}

