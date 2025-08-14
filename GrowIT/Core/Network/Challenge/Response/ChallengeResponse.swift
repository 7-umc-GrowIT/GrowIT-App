//
//  ChallengeResponse.swift
//  GrowIT
//
//  Created by 허준호 on 1/29/25.
//


import Foundation

// 챌린지 선택 후 응답 DTO
struct ChallengeSelectResponseDTO: Decodable{
    let selectedChallenges: [SelectedChallenge]
}
        
struct SelectedChallenge: Decodable{
    let id: Int
    let dtype: String
    let title: String
    let content: String
    let time: Int
}

// 챌린지 인증 후 응답 DTO
struct ChallengeProveResponseDTO: Decodable{
    let id: Int
    let title: String
    let certificationImage: String
    let thoughts: String
    let time: Int
    let certificationDate: String
}

// 단일 챌린지 조회 응답 DTO, 챌린지 인증 후 응답 DTO
struct ChallengeDTO: Decodable{
    let id: Int
    let title: String
    let certificationImageUrl: String
    let thoughts: String
    let time: Int
    let certificationDate: String
}

// 단일 챌린지 삭제 응답 DTO
struct ChallengeDeleteResponseDTO: Decodable{
    let id: Int
    let message: String
}

// 단일 챌린지 수정 응답 DTO
struct ChallengePatchResponseDTO: Decodable{
    let certificationImageUrl: String
    let thoughts: String
}

// 챌린지 홈 조회 응답 DTO
//struct ChallengeHomeResponseDTO: Decodable{
//    let challengeKeywords: [String]
//    let recommendedChallenges: [RecommendedChallengeDTO]
//    let challengeReport: ChallengeReportDTO
//}

// 챌린지 현황 조회 응답 DTO
//struct ChallengeStatusResponseDTO: Decodable{
//    let userChallenges: [UserChallenge]
//}
//
//struct UserChallenge: Decodable{
//    let id: Int
//    let title: String
//    let dtype: String
//    let time: Int
//    let completed: Bool
//}


//struct RecommendedChallengeDTO: Decodable{
//    let id: Int
//    let title: String
//    let content: String
//    let dtype: String
//    let time: Int
//    let completed: Bool
//}

//struct ChallengeReportDTO: Decodable{
//    let totalCredits: Int
//    let totalDiaries: Int
//    let diaryDate: String
//}


struct ChallengeSelectResultDTO: Codable {
    let selectedChallenges: [SelectedChallengeDTO]
}

struct SelectedChallengeDTO: Codable {
    let id: Int
    let dtype: String
    let title: String
    let content: String
    let time: Int
}
