//
//  ItemEndpoint.swift
//  GrowIT
//
//  Created by 오현민 on 1/27/25.
//

import Foundation
import Moya

enum ItemEndpoint {
    // Get
    case getItem(category: String)
    
    // Post
    case postItemPurchase(itemId: Int)
    
    // Patch
    case patchItemState(itemId: Int, data: ItemRequestDTO)
}

extension ItemEndpoint: TargetType {
    var baseURL: URL {
        guard let url = URL(string: Constants.API.itemURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .postItemPurchase(let itemId):
            return "/\(itemId)/purchase"
        case .patchItemState(let itemId, _):
            return "/\(itemId)"
        default:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postItemPurchase:
            return .post
        case .patchItemState:
            return .patch
        default:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getItem(let category):
            return .requestParameters(parameters: ["category": category], encoding: URLEncoding.queryString)
        case .postItemPurchase(let itemId):
            return .requestJSONEncodable(itemId)
        case .patchItemState(_, let data):
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
