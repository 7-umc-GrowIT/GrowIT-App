//
//  TermsService.swift
//  GrowIT
//
//  Created by 강희정 on 1/30/25.
//

import Foundation
import Moya

class TermsService {
    
    private let provider = MoyaProvider<TermsEndpoints>()
    
    func fetchTerms(completion: @escaping (Result<[TermsData], Error>) -> Void) {
        provider.request(.getTerms) { result in
            switch result {
            case .success(let response):
                do {
                    let decodedResponse = try JSONDecoder().decode(TermsResponse.self, from: response.data)
                    if decodedResponse.isSuccess {
                        completion(.success(decodedResponse.result)) // 배열 형태로 변경
                    } else {
                        completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: decodedResponse.message])))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func agreeTerms(terms: [UserTermDTO], completion: @escaping (Result<Bool, Error>) -> Void) {
        provider.request(.agreeTerms(terms: terms)) { result in
            switch result {
            case .success(let response):
                do {
                    let decodedResponse = try JSONDecoder().decode(BaseResponse.self, from: response.data)
                    if decodedResponse.isSuccess {
                        completion(.success(true))
                    } else {
                        completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: decodedResponse.message])))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


// 공통 응답 모델
struct BaseResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
}
