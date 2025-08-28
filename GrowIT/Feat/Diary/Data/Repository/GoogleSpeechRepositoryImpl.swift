//
//  SpeechToTextRepositoryImpl.swift
//  GrowIT
//
//  Created by 허준호 on 8/16/25.
//

import Foundation

class GoogleSpeechRepositoryImpl: GoogleSpeechRepository {
    private let dataSource: GoogleSpeechDataSource
    
    init(dataSource: GoogleSpeechDataSource) {
        self.dataSource = dataSource
    }
    
    func recognizeSpeech(audioData: Data) async throws -> SpeechRecognitionResult {
        // Base64로 오디오 데이터 인코딩
        let base64Audio = audioData.base64EncodedString()
        
        // API 호출
        let response = try await dataSource.speechToText(audioContent: base64Audio)
        
        // 결과 파싱
        guard let result = response.results.first?.alternatives.first else {
            throw SpeechRecognitionError.noResults
        }
        
        return SpeechRecognitionResult(
            text: result.transcript,
            confidence: result.confidence,
            languageCode: "ko-KR"
        )
    }
    
    func synthesizeSpeech(text: String) async throws -> Data {
        return try await dataSource.textToSpeech(text: text)
    }
}
