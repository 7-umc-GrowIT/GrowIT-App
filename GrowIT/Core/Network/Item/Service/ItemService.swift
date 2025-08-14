//
//  ItemShopService.swift
//  GrowIT
//
//  Created by 오현민 on 1/27/25.
//

import Foundation
import Moya

final class ItemService: NetworkManager {
    
    let provider: MoyaProvider<ItemEndpoint>
    
    init(provider: MoyaProvider<ItemEndpoint>? = nil) {
        let plugins: [PluginType] = [
//            NetworkLoggerPlugin(configuration: .init(logOptions: [.requestHeaders, .verbose]))
            AuthPlugin()
        ]
        
        self.provider = provider ?? MoyaProvider<ItemEndpoint>(plugins: plugins)
    }
    
    // 아이템 구매 API
    func postItemPurchase(itemId: Int, completion: @escaping (Result<ItemPostResponseDTO, NetworkError>) -> Void) {
        request(
            target: .postItemPurchase(itemId: itemId),
            decodingType: ItemPostResponseDTO.self,
            completion: completion
        )
    }
    
    // 아이템 착용 상태 변경 API
    func patchItemState(itemId: Int, data: ItemRequestDTO, completion: @escaping(Result<ItemPatchResponseDTO, NetworkError>) -> Void) {
        request(
            target: .patchItemState(itemId: itemId, data: data),
            decodingType: ItemPatchResponseDTO.self,
            completion: completion
        )
    }
    
    // 카테고리별 아이템 조회 API
    func getItemList(category: String, completion: @escaping(Result<ItemGetResponseDTO, NetworkError>) -> Void) {
        request(
            target: .getItem(category: category),
            decodingType: ItemGetResponseDTO.self,
            completion: completion
        )
    }
    
    
}
