//
//  GroResponse.swift
//  GrowIT
//
//  Created by 오현민 on 1/29/25.
//

import Foundation

struct GroPostResponseDTO: Decodable {
    let id, user_id: Int
    let name: String
    let level: Int
}

struct GroGetResponseDTO: Decodable {
    let gro: Gro
    let equippedItems: [EquippedItem]
}

struct Gro: Decodable {
    let id: Int
    let level: Int
    let groImageUrl: String
}

struct EquippedItem: Decodable {
    let id: Int
    let name: String
    let category: String
    let itemImageUrl: String
}
