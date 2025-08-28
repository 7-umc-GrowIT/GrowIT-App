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
    
    // Post
    case postPaymentCredits(data: UserPostRequestDTO)
    
    // Patch
    case patchPassword(data: UserPatchRequestDTO)
    case patchUserWithdraw
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
        case .postPaymentCredits(let data):
            return "/credits/payment"
        case .patchPassword(let data):
            return "/password"
        case .patchUserWithdraw:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postPaymentCredits:
            return .post
        case .patchPassword, .patchUserWithdraw:
            return .patch
        default:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getCredits, .getTotalCredits, .getMypage:
            return .requestPlain
        case .postPaymentCredits(let data):
            return .requestJSONEncodable(data)
        case .patchPassword(let data):
            return .requestJSONEncodable(data)
            // BE API 개발 진행중 (임시로 적어둔 상태)
        case .patchUserWithdraw:
            return .requestPlain
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
