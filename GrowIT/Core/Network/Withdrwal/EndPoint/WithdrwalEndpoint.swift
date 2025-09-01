//
//  WithdrwalEndpoint.swift
//  GrowIT
//
//  Created by 오현민 on 8/31/25.
//

import Foundation
import Moya

enum WithdrwalEndpoint {
    // Get
    case getReasons
}

extension WithdrwalEndpoint: TargetType {
    var baseURL: URL {
        guard let url = URL(string: Constants.API.withdrawalURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getReasons:
            return "/reasons"
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getReasons:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return [
            "Content-type": "application/json",
            "accept": "*/*",
        ]
    }
}
