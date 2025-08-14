//
//  S3Endpoint.swift
//  GrowIT
//
//  Created by 허준호 on 2/12/25.
//

import Foundation
import Moya

enum S3Endpoint {
    // Get
    case getDownloadUrl(folder: String, fileName: String)
    
    // Put
    case putUploadUrl(folder: String, fileName: String)
}

extension S3Endpoint: TargetType {
    var baseURL: URL {
        guard let url = URL(string: Constants.API.s3URL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case.getDownloadUrl(_,_):
            return "/download-url"
        case.putUploadUrl(_,_):
            return "/upload-url"
        default:
            return "/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .putUploadUrl:
            return .put
        default :
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .getDownloadUrl(folder: _ , fileName: let fileName), .putUploadUrl(folder: _ , fileName: let fileName):
            return .requestParameters(
                parameters: ["folder": "challenges", "fileName": fileName],
                encoding: URLEncoding.queryString)
            
        }
    }
    
    var headers: [String : String]? {
        return [ "Content-type": "application/json"]
    }
    
    
}
