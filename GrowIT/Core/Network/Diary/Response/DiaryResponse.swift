//
//  DiaryResponse.swift
//  GrowIT
//
//  Created by 이수현 on 1/18/25.
//

import Foundation

struct DiaryTextPostResponseDTO: Decodable {
    let diaryId: Int
    let content: String
    let date: String
}

struct DiaryVoicePostResponseDTO: Decodable {
    let chat: String
}

struct DiaryGetDatesResponseDTO: Decodable {
    let diaryDateList: [DiaryDateDTO]
    let listSize: Int
}

struct DiaryDateDTO: Decodable {
    let diaryId: Int
    let date: String
}

struct DiaryGetAllResponseDTO: Decodable {
    let diaryList: [DiaryDTO]
    let listSize: Int
}

struct DiaryDTO: Decodable {
    let diaryId: Int
    let content: String
    let date: String
}

struct DiaryResponseDTO: Decodable {
    let diaryId: Int
    let content: String
    let date: String
    let creditInfo: CreditInfo
}

struct DiaryPatchResponseDTO: Decodable {
    let diaryId: Int
    let content: String
}

struct DiaryDeleteResponseDTO: Decodable {
    let message: String
}

struct DiaryAnalyzeResponseDTO: Decodable {
    let emotionKeywords: [EmotionKeyword]
    let recommendedChallenges: [RecommendedDiaryChallengeDTO]
}

struct EmotionKeyword: Decodable {
    let id: Int
    let keyword: String
}

struct RecommendedDiaryChallengeDTO: Decodable {
    let id: Int
    let title: String
    let content: String
    let time: Int
    let challengeType: String
}
