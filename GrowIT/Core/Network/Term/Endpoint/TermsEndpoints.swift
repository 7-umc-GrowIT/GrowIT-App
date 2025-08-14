//
//  TermsEndpoints.swift
//  GrowIT
//
//  Created by 강희정 on 1/30/25.
//

import Foundation
import Moya

enum TermsEndpoints {
    case getTerms
    case agreeTerms(terms: [UserTermDTO])
}

extension TermsEndpoints: TargetType {
    
    var baseURL: URL {
        guard let url = URL(string: Constants.API.baseURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getTerms:
            return "/terms"
        case .agreeTerms:
            return "/terms/agree"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getTerms:
            return .get
        case .agreeTerms:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getTerms:
            return .requestPlain
        case .agreeTerms(let terms):
            return .requestJSONEncodable(["userTerms": terms]) // JSON 래핑 확인 후 적용
        }
    }
    
    var headers: [String: String]? {
           switch self {
           case .getTerms, .agreeTerms:
               return ["Content-Type": "application/json"]
           }
       }

}
