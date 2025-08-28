//
//  STTResponse.swift
//  GrowIT
//
//  Created by 허준호 on 8/16/25.
//

struct STTResponse: Codable {
    let results: [RecognitionResult]
}

struct RecognitionResult: Codable {
    let alternatives: [SpeechAlternative]
}

struct SpeechAlternative: Codable {
    let transcript: String
    let confidence: Float
}
