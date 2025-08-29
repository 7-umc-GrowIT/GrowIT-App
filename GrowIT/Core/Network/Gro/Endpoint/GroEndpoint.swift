//
//  GroEndpoint.swift
//  GrowIT
//
//  Created by 오현민 on 1/29/25.
//

import Foundation
import Moya

enum GroEndpoint {
    // Get
    case getGroImage
    
    // Post
    case postGroCreate(data: GroRequestDTO)
    
    // Patch
    case patchGroChangeNickname(data: GroChangeNicknameRequestDTO)
}

extension GroEndpoint: TargetType {
    var baseURL: URL {
        guard let url = URL(string: Constants.API.GroURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .patchGroChangeNickname:
            return "/nickname"
        default:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getGroImage:
            return .get
        case .postGroCreate:
            return .post
        case .patchGroChangeNickname:
            return .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getGroImage:
            return .requestPlain
        case .postGroCreate(let data):
            return .requestJSONEncodable(data)
        case .patchGroChangeNickname(let data):
            return .requestJSONEncodable(data)
        }
    }
    
    var headers: [String : String]? {
        return [
            "Content-type": "application/json",
            "accept": "*/*",
            // 테스트용 임시토큰
            "Authorization": "Bearer "
        ]
    }
    
    
}
