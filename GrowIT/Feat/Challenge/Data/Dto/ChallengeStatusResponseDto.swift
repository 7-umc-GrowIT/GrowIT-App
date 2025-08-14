//
//  ChallengeStatusResponseDto.swift
//  GrowIT
//
//  Created by 허준호 on 7/10/25.
//

import Foundation

// DTO
struct ChallengeStatusResponseDTO: Decodable {
    let content: [UserChallengeDto]
    let currentPage: Int
    let totalPages: Int
    let totalElements: Int
    let first: Bool
    let last: Bool
}

struct UserChallengeDto: Decodable {
    let id: Int
    let title: String
    let dtype: String
    let time: Int
    let completed: Bool
}


