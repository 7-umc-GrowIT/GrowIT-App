//
//  ChallengeService.swift
//  GrowIT
//
//  Created by 허준호 on 1/29/25.
//

import Foundation
import Moya

final class ChallengeService: NetworkManager {
    typealias Endpoint = ChallengeEndpoint
    
    let provider: MoyaProvider<ChallengeEndpoint>
    
    init(provider: MoyaProvider<ChallengeEndpoint>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: [.requestBody, .requestMethod, .requestHeaders, .successResponseBody, .errorResponseBody])),
            AuthPlugin()
        ]
        
        self.provider = provider ?? MoyaProvider<ChallengeEndpoint>(plugins: plugins)
    }

    /// Post Prove Challenge API
    func postProveChallenge(challengeId: Int, data: ChallengeRequestDTO, completion: @escaping (Result<ChallengeDTO, NetworkError>) -> Void) {
        request(target: .postProveChallenge(challengeId: challengeId, data: data), decodingType: ChallengeDTO.self, completion: completion)
    }
    
    /// Fetch Challenge API(단일 챌린지 조회)
    func fetchChallenge(challengeId: Int, completion: @escaping (Result<ChallengeDTO, NetworkError>) -> Void) {
        request(target: .getChallengeById(challengeId: challengeId), decodingType: ChallengeDTO.self, completion: completion)
    }
    
    /// Delete Challenge API
    func deleteChallenge(challengeId: Int, completion: @escaping (Result<ChallengeDeleteResponseDTO, NetworkError>) -> Void) {
        request(target: .deleteChallengeById(challengeId: challengeId), decodingType: ChallengeDeleteResponseDTO.self, completion: completion)
    }
    
    /// Patch Challenge API
    func patchChallenge(challengeId: Int, data: ChallengeRequestDTO, completion: @escaping (Result<ChallengePatchResponseDTO, NetworkError>) -> Void) {
        request(target: .patchChallengeById(challengeId: challengeId, data: data), decodingType: ChallengePatchResponseDTO.self, completion: completion)
    }
    
    
    /// Fetch Challenge Home  API
    func fetchChallengeHome(completion: @escaping (Result<ChallengeHomeResponseDTO, NetworkError>) -> Void){
        request(target: .getSummaryChallenge, decodingType: ChallengeHomeResponseDTO.self, completion: completion)
    }
    
    /// Fetch Challenge Status API
    func fetchChallengeStatus(challengeType: String, completed: String, page: Int, completion: @escaping (Result<ChallengeStatusResponseDTO, NetworkError>) -> Void){
        request(target: .getAllChallenges(challengeType: challengeType, completed: completed, page: page), decodingType: ChallengeStatusResponseDTO.self, completion: completion)
    }
    
    func postSelectedChallenge(data: [ChallengeSelectRequestDTO], completion: @escaping (Result<ChallengeSelectResponseDTO, NetworkError>) -> Void) {
        request(target: .postSelectChallenge(data: data), decodingType: ChallengeSelectResponseDTO.self, completion: completion)
    }
    
    func postPresignedUrl(data: PresignedUrlRequestDTO, completion: @escaping (Result<PresignedUrlResponseDTO, NetworkError>) -> Void){
        request(target: .postPresignedUrl(data: data), decodingType: PresignedUrlResponseDTO.self, completion: completion)
    }
}
