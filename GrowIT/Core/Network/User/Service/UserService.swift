//
//  UserService.swift
//  GrowIT
//
//  Created by 오현민 on 1/31/25.
//

import Foundation
import Moya

final class UserService: NetworkManager {
    
    let provider: MoyaProvider<UserEndpoint>
    
    init(provider: MoyaProvider<UserEndpoint>? = nil) {
        let plugins: [PluginType] = [
//            NetworkLoggerPlugin(configuration: .init(logOptions: [.requestHeaders, .verbose]))
            AuthPlugin()
        ]
        
        self.provider = provider ?? MoyaProvider<UserEndpoint>(plugins: plugins)
    }
    
    // 크레딧 구매 API
    func postUserCreditPayment(data: UserPostRequestDTO, completion: @escaping(Result<UserPostResponseDTO, NetworkError>) -> Void) {
        request(
            target: .postPaymentCredits(data: data),
            decodingType: UserPostResponseDTO.self,
            completion: completion
        )
    }
    
    // 비밀번호 변경 API
    func patchUserPassword(data: UserPatchRequestDTO, completion: @escaping(Result<UserPatchResponseDTO, NetworkError>) -> Void) {
        let provider = MoyaProvider<UserEndpoint>(plugins: []) // AccessToken 플러그인 없이 실행

        provider.request(.patchPassword(data: data)) { result in
            switch result {
            case .success(let response):
                guard (200...299).contains(response.statusCode) else {
                    completion(.failure(.serverError(statusCode: response.statusCode, message: "서버 에러")))
                    return
                }
                do {
                    let decodedResponse = try JSONDecoder().decode(UserPatchResponseDTO.self, from: response.data)
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(.decodingError))
                }

            case .failure(let error):
                completion(.failure(.networkError(message: error.localizedDescription)))
            }
        }
    }



    // 현재 보유중인 크레딧 조회 API
    func getUserCredits(completion: @escaping(Result<UserGetCreditResponseDTO, NetworkError>) -> Void) {
        request(
            target: .getCredits,
            decodingType: UserGetCreditResponseDTO.self,
            completion: completion
        )
    }
    
    // 누적 크레딧 조회 API
    func getUserTotalCredits(completion: @escaping(Result<UserGetTotalCreditResponseDTO, NetworkError>) -> Void) {
        request(
            target: .getTotalCredits,
            decodingType: UserGetTotalCreditResponseDTO.self,
            completion: completion
        )
    }
}


