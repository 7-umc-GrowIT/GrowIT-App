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
    case postSignUp(data: AuthSignUpRequestDTO)
    case postSignUpSocial(data: AuthSignUpSocialRequestDTO)
    case postReissueToken(data: AuthReissueRequestDTO)
    case postLogout
    case postLogin(data: AuthLoginRequestDTO)
    case postLoginKakao(data: AuthLoginSocialRequestDTO)
    case postLoginApple(data: AuthLoginSocialRequestDTO)
    case postEmailVerify(data: AuthEmailVerifyRequestDTO)
    case postEmailSend(type: String, data: AuthEmailSendReqeustDTO)
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
        case .postSignUp:
            return "/signup"
        case .postSignUpSocial:
            return "/signup/social"
        case .postReissueToken:
            return "/reissue"
        case .postLogin:
            return "/login"
        case .postLogout:
            return "/logout"
        case .postLoginKakao:
            return "/login/kakao"
        case .postLoginApple:
            return "/login/apple"
        case .postEmailVerify:
            return "/email/verify"
        case .postEmailSend:
            return "/email/send"
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .postSignUp(let data):
            return .requestJSONEncodable(data)
        case .postSignUpSocial(let data):
            return .requestJSONEncodable(data)
        case .postReissueToken(let data):
            return .requestJSONEncodable(data)
        case .postLogin(let data):
            return .requestJSONEncodable(data)
        case .postLogout:
            return .requestPlain
        case .postLoginKakao(let data):
            return .requestJSONEncodable(data)
        case .postLoginApple(let data):
            return .requestJSONEncodable(data)
        case .postEmailVerify(let data):
            return .requestJSONEncodable(data)
        case .postEmailSend(let type, let data):
            return .requestCompositeParameters(
                bodyParameters: ["email": data.email], // JSON 바디
                bodyEncoding: JSONEncoding.default,
                urlParameters: ["type": type] // 쿼리 스트링
            )
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
