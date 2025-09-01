//
//  ChallengeEndpoint.swift
//  GrowIT
//
//  Created by 허준호 on 1/29/25.
//

import Foundation
import Moya

enum ChallengeEndpoint {
    // Get
    case getChallengeById(challengeId: Int)
    case getAllChallenges(challengeType: String, completed: String, page: Int)
    case getSummaryChallenge
    
    // Post
    case postSelectChallenge(data: [ChallengeSelectRequestDTO])
    case postProveChallenge(challengeId: Int, data: ChallengeRequestDTO)
    case postPresignedUrl(data: PresignedUrlRequestDTO)
    
    // Delete
    case deleteChallengeById(challengeId: Int)
    
    // Put
    case patchChallengeById(challengeId: Int, data: ChallengeRequestDTO)
}

extension ChallengeEndpoint: TargetType {
    var baseURL: URL {
        guard let url = URL(string: Constants.API.challengeURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case.getChallengeById(let challengeId):
            return "/\(challengeId)"
        case.getAllChallenges:
            return "/status"
        case.postSelectChallenge:
            return "/select"
        case.postProveChallenge(let challengeId, _):
            return "/\(challengeId)"
        case.postPresignedUrl:
            return "/presigned-url"
        case.deleteChallengeById(let challengeId):
            return "/\(challengeId)"
        case.patchChallengeById(let challengeId, _):
            return "/\(challengeId)"
        default:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postSelectChallenge, .postProveChallenge, .postPresignedUrl:
            return .post
        case .deleteChallengeById:
            return .delete
        case .patchChallengeById:
            return .patch
        default :
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .postSelectChallenge(let data):
            return .requestJSONEncodable(data)
        case .postPresignedUrl(let data):
            return .requestJSONEncodable(data)
        case .deleteChallengeById(_), .getChallengeById(_), .getSummaryChallenge:
            return .requestPlain
        case .postProveChallenge(_, let data), .patchChallengeById(_, let data):
            return .requestJSONEncodable(data)
        case .getAllChallenges(challengeType: let challengeType, completed: let completed, page: let page):
            return .requestParameters(
                parameters: ["challengeType": challengeType, "completed": completed, "page": page],
                encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return [
            "Content-Type": "application/json"
        ]
    }
    
    
}
