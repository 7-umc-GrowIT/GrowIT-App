//
//  GroService.swift
//  GrowIT
//
//  Created by 오현민 on 1/29/25.
//

import Foundation
import Moya

final class GroService: NetworkManager {
    typealias Endpoint = GroEndpoint
    
    let provider: MoyaProvider<Endpoint>
    
    init(provider: MoyaProvider<GroEndpoint>? = nil) {
        let plugins: [PluginType] = [
            // NetworkLoggerPlugin(configuration: .init(logOptions: [.requestMethod, .successResponseBody])),
            AuthPlugin()
        ]
        
        self.provider = provider ?? MoyaProvider<GroEndpoint>(plugins: plugins)
    }
    
    // 그로와 착용아이템 이미지 조회 API
    func getGroImage(completion: @escaping (Result<GroGetResponseDTO, NetworkError>) -> Void) {
        request(
            target: .getGroImage,
            decodingType: GroGetResponseDTO.self,
            completion: completion
        )
    }
    
    // 그로 캐릭터 생성 API
    func postGroCreate(data: GroRequestDTO, completion: @escaping (Result<GroPostResponseDTO, NetworkError>) -> Void) {
        request(
            target: .postGroCreate(data: data),
            decodingType: GroPostResponseDTO.self,
            completion: completion
        )
    }
}
