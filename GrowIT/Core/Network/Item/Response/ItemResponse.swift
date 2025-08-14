//
//  ItemShopResponse.swift
//  GrowIT
//
//  Created by 오현민 on 1/27/25.
//

import Foundation

struct ItemPostResponseDTO: Decodable {
    let itemId: Int
    let itemName: String
}

struct ItemPatchResponseDTO: Decodable {
    let itemId: Int
    let category, status, updatedAt: String
}

struct ItemGetResponseDTO: Decodable {
    let itemList: [ItemList]
}

struct ItemList: Decodable {
    let id: Int
    let name: String
    let price: Int
    let imageUrl, groImageUrl, category: String
    let status: String?
    let purchased: Bool
}
