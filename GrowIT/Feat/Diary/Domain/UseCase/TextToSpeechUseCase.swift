//
//  TextToSpeechUseCase.swift
//  GrowIT
//
//  Created by 허준호 on 8/16/25.
//

import Foundation

class TextToSpeechUseCase {
    private let googleSpeechRepository: GoogleSpeechRepository
    
    init(googleSpeechRepository: GoogleSpeechRepository) {
        self.googleSpeechRepository = googleSpeechRepository
    }
    
    func execute(text: String) async throws -> Data {
        return try await googleSpeechRepository.synthesizeSpeech(text: text)
    }
}
