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
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getGroImage:
            return .requestPlain
        case .postGroCreate(let data):
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
