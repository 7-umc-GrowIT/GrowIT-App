//
//  RecognizeSpeechUseCase.swift
//  GrowIT
//
//  Created by 허준호 on 8/16/25.
//

import Foundation

class SpeechToTextUseCase {
    private let googleSpeechRepository: GoogleSpeechRepository
    
    init(googleSpeechRepository: GoogleSpeechRepository) {
        self.googleSpeechRepository = googleSpeechRepository
    }
    
    func execute(audioData: Data) async throws -> String {
        guard !audioData.isEmpty else {
            throw SpeechRecognitionError.audioFormatError
        }
        let recognizedData = try await googleSpeechRepository.recognizeSpeech(audioData: audioData)
        
        return recognizedData.text

    }
}
