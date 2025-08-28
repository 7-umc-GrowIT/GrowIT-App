//
//  SpeechToTextReposiotry.swift
//  GrowIT
//
//  Created by 허준호 on 8/16/25.
//

import Foundation

protocol GoogleSpeechRepository {
    func recognizeSpeech(audioData: Data) async throws -> SpeechRecognitionResult
    func synthesizeSpeech(text: String) async throws -> Data
}
