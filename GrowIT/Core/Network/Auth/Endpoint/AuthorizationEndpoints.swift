//
//  AuthorizationEndpoints.swift
//  GrowIT
//
//  Created by 이수현 on 1/26/25.
//

import Foundation
import Moya

enum AuthorizationEndpoints {
    // Post
    case postVerification(data: EmailVerifyRequest) // 이메일 인증번호 확인 api
    case postEmailSignUp(data: EmailSignUpRequest) // 이메일 회원가입 api
    case postSocialSignUp(data: SocialSignUpRequest) // 소셜 간편 가입 api
    case postReissueToken(data: ReissueTokenRequest) // 토큰 재발급 api
    case postKakaoLogin(code: String)
    case postEmailLogin(data: EmailLoginRequest)
    case postSendEmailVerification(type: String, data: SendEmailVerifyRequest) // 인증 메일 전송 api
   
    // Patch
    case patchSignOut
    case fetchSignUpTerms
}

extension AuthorizationEndpoints: TargetType {
    var baseURL: URL {
        guard let url = URL(string: Constants.API.authURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .postVerification:
            return "/verification"
        case .postEmailSignUp:
            return "/signup"
        case .postSocialSignUp:
            return "/signup/social"
        case .postReissueToken:
            return "/reissue"
        case .postKakaoLogin:
            return "/login/kakao"
        case .postEmailLogin:
            return "/login"
        case .postSendEmailVerification:
            return "/email"
        case .patchSignOut:
            return "/signout"
        case .fetchSignUpTerms:
            return "/auth/terms"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchSignUpTerms:
            return .get
        case .patchSignOut:
            return .patch
        default:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .postVerification(let data):
            return .requestJSONEncodable(data)
        case .postEmailSignUp(let data):
            return .requestJSONEncodable(data)
        case .postReissueToken(let data):
            return .requestJSONEncodable(data)
        case .postKakaoLogin(let code):
            return .requestParameters(parameters: ["code": code], encoding: URLEncoding.queryString)
        case .postEmailLogin(let data):
            return .requestJSONEncodable(data)
        case .postSendEmailVerification(let type, let data):
            return .requestCompositeParameters(
                bodyParameters: ["email": data.email], // JSON 바디
                bodyEncoding: JSONEncoding.default,
                urlParameters: ["type": type] // 쿼리 스트링
            )
        case .patchSignOut:
            return .requestPlain
        case .fetchSignUpTerms:
            return .requestPlain
        case .postSocialSignUp(data: let data):
            return .requestJSONEncodable(data)
        }
    }
    
    var headers: [String : String]? {
        var headers: [String: String] = [
            "Content-type": "application/json"
        ]
        
        switch self {
        case .postReissueToken:
            if let cookies = HTTPCookieStorage.shared.cookies {
                let cookieHeader = HTTPCookie.requestHeaderFields(with: cookies)
                for (key, value) in cookieHeader {
                    headers[key] = value // 쿠키를 헤더에 추가
                }
            }
        default:
            break
        }
        return headers
    }

}
