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

struct DiaryPatchResponseDTO: Decodable {
    let diaryId: Int
    let content: String
}

struct DiaryDeleteResponseDTO: Decodable {
    let message: String
}

struct DiaryAnalyzeResponseDTO: Decodable {
    let emotionKeywords: [EmotionKeyword]
    let recommendedChallenges: [RecommendedChallenge]
}

struct EmotionKeyword: Decodable {
    let id: Int
    let keyword: String
}

struct RecommendedChallenge: Decodable {
    let id: Int
    let title: String
    let content: String
    let time: Int
    let type: String
    let completed: Bool
}

extension RecommendedChallenge {
    init(dto: RecommendedChallengeDTO){
        self.id = dto.id
        self.title = dto.title
        self.content = dto.content
        self.time = dto.time
        self.type = dto.dtype
        self.completed = dto.completed
    }
}
