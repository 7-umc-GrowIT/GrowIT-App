//
//  UserEndpoint.swift
//  GrowIT
//
//  Created by 오현민 on 1/31/25.
//

import Foundation
import Moya

enum UserEndpoint {
    // Get
    case getCredits
    case getTotalCredits
    case getMypage
    case getMeEmail
    
    // Post
    case postPaymentCredits(data: UserPostRequestDTO)
    
    // Patch
    case patchPassword(data: UserPatchRequestDTO)
    
    // Delete
    case deleteUser(data: UserDeleteRequestDTO)
}

extension UserEndpoint: TargetType {
    var baseURL: URL {
        guard let url = URL(string: Constants.API.userURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getCredits:
            return "/credits"
        case .getTotalCredits:
            return "/credits/total"
        case .getMypage:
            return "/mypage"
        case .getMeEmail:
            return "/me/email"
        case .postPaymentCredits:
            return "/credits/payment"
        case .patchPassword:
            return "/password"
        case .deleteUser:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postPaymentCredits:
            return .post
        case .patchPassword:
            return .patch
        case .deleteUser:
            return .delete
        default:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getCredits, .getTotalCredits, .getMypage, .getMeEmail:
            return .requestPlain
        case .postPaymentCredits(let data):
            return .requestJSONEncodable(data)
        case .patchPassword(let data):
            return .requestJSONEncodable(data)
        case .deleteUser(let data):
            return .requestJSONEncodable(data)
        }
    }
    
    var headers: [String : String]? {
        return [
            "Content-type": "application/json",
            "accept": "*/*",
//            // 테스트용 임시토큰
//            "Authorization": "Bearer "
        ]
    }
}
