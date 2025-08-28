//
//  GetSTTResponseUseCase.swift
//  GrowIT
//
//  Created by 허준호 on 8/27/25.
//

import Foundation

class GetSTTResponseUseCase {
    private let diaryVoiceRepository: DiaryVoiceRepository
    
    init(diaryVoiceRepository: DiaryVoiceRepository) {
        self.diaryVoiceRepository  = diaryVoiceRepository
    }
    
    func execute(chat: String) async throws -> String {
        return try await diaryVoiceRepository.postVoiceDiary(chat: chat)
    }
}

