//
//  WithdrwalService.swift
//  GrowIT
//
//  Created by 오현민 on 8/31/25.
//

import Foundation
import Moya

final class WithdrwalService: NetworkManager {
    let provider: MoyaProvider<WithdrwalEndpoint>
    
    init(provider: MoyaProvider<WithdrwalEndpoint>? = nil) {
        let plugins: [PluginType] = [
            // NetworkLoggerPlugin(configuration: .init(logOptions: [.requestHeaders, .verbose]))
            AuthPlugin()
        ]
        
        self.provider = provider ?? MoyaProvider<WithdrwalEndpoint>(plugins: plugins)
    }
    
    // 탈퇴목록 이유 조회 API
    func getWithdrawalReasons(completion: @escaping(Result<[WithdrwalReasonsResponseDTO], NetworkError>) -> Void) {
        request(
            target: .getReasons,
            decodingType: [WithdrwalReasonsResponseDTO].self,
            completion: completion
        )
    }
}
