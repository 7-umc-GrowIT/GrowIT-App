//
//  ChallengeHomeResponseDto.swift
//  GrowIT
//
//  Created by 허준호 on 6/4/25.
//

import Foundation

struct ChallengeHomeResponseDTO: Decodable{
    let challengeKeywords: [String]
    let recommendedChallenges: [RecommendedChallengeDTO]
    let challengeReport: ChallengeReportDTO
}

struct RecommendedChallengeDTO: Decodable{
    let id: Int
    let title: String
    let content: String
    let challengeType: String
    let time: Int
    let completed: Bool
}

struct ChallengeReportDTO: Decodable{
    let totalCredits: Int
    let totalDiaries: Int
    let diaryDate: String
}
