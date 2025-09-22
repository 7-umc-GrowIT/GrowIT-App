//
//  DiaryRepository.swift
//  GrowIT
//
//  Created by 허준호 on 8/16/25.
//

protocol DiaryVoiceRepository {
    func postVoiceDiary(data: DiaryVoiceRequestDTO) async throws -> String
    
    func postVoiceDiaryDate(date: String) async throws -> Diary
}
