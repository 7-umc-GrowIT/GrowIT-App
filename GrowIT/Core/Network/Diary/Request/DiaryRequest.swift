//
//  DiaryRequest.swift
//  GrowIT
//
//  Created by 이수현 on 1/18/25.
//

import Foundation

struct DiaryRequestDTO: Codable {
    let content: String
    let date: String
}

struct DiaryVoiceRequestDTO: Codable {
    let chat: String
}

struct DiaryVoiceDateRequestDTO: Codable {
    let date: String
}

struct DiaryPatchDTO: Codable {
    let content: String
}
