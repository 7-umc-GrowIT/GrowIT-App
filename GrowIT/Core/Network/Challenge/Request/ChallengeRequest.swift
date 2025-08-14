//
//  ChallengeRequest.swift
//  GrowIT
//
//  Created by 허준호 on 1/29/25.
//

import Foundation

struct ChallengeRequestDTO: Codable {
    let certificationImageUrl: String
    let thoughts: String
}

struct ChallengeSelectRequestDTO: Codable {
    let challengeIds: [Int]
    let dtype: String
    let date: String
}

typealias ChallengeSelectRequestListDTO = [ChallengeSelectRequestDTO]
