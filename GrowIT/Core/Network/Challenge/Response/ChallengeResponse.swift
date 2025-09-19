//
//  ChallengeResponse.swift
//  GrowIT
//
//  Created by 허준호 on 1/29/25.
//


import Foundation

// 챌린지 인증 후 응답 DTO
struct ChallengeProveResponseDTO: Decodable{
    let creditInfo: CreditInfo
}

struct CreditInfo: Decodable {
    let granted: Bool
    let amount: Int
}

// 단일 챌린지 조회 응답 DTO, 챌린지 인증 후 응답 DTO
struct ChallengeDTO: Decodable{
    let id: Int
    let title: String
    let certificationImageUrl: String
    let certificationImageName: String
    let thoughts: String
    let time: Int
    let certificationDate: String
}

// 단일 챌린지 삭제 응답 DTO
struct ChallengeDeleteResponseDTO: Decodable{
    let id: Int
    let message: String
}

struct PresignedUrlResponseDTO: Decodable {
    let presignedUrl: String
    let fileName: String
}
