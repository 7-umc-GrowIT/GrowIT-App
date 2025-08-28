//
//  STTRequest.swift
//  GrowIT
//
//  Created by 허준호 on 8/16/25.
//

struct STTRequest: Codable {
    let config: RecognitionConfig
    let audio: AudioContent
}

struct RecognitionConfig: Codable {
    let encoding: String
    let sampleRateHertz: Int
    let languageCode: String
    let enableAutomaticPunctuation: Bool
    
    init(encoding: String, sampleRateHertz: Int, languageCode: String) {
        self.encoding = encoding
        self.sampleRateHertz = sampleRateHertz
        self.languageCode = languageCode
        self.enableAutomaticPunctuation = true
    }
}

struct AudioContent: Codable {
    let content: String // Base64 encoded audio
}
