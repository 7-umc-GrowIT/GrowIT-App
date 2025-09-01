//
//  GoogleSpeechRemoteDataSource.swift
//  GrowIT
//
//  Created by 허준호 on 8/16/25.
//

import Foundation
import Moya

protocol GoogleSpeechDataSource {
    func speechToText(audioContent: String) async throws -> STTResponse
    func textToSpeech(text: String) async throws -> Data
}

class GoogleSpeechDataSourceImpl: GoogleSpeechDataSource {
    private let provider: MoyaProvider<SpeechAPI>
    private let apiKey: String = Bundle.main.googleSpeechAPIKey
    
    init(provider: MoyaProvider<SpeechAPI> = MoyaProvider<SpeechAPI>()) {
        self.provider = provider
        
        // API 키 유효성 검사
        guard !apiKey.isEmpty else {
            fatalError("Google Speech API Key가 Info.plist에 설정되지 않았습니다.")
        }
    }
    
    func speechToText(audioContent: String) async throws -> STTResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.recognize(audioContent: audioContent, apiKey: apiKey)) { result in
                switch result {
                case .success(let response):
                    do {
                        let sttResponse = try JSONDecoder().decode(STTResponse.self, from: response.data)
                        continuation.resume(returning: sttResponse)
                    } catch {
                        // 기존 방식으로 파싱 시도 (호환성)
                        do {
                            if let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any],
                               let results = json["results"] as? [[String: Any]] {
                                
                                let recognitionResults = results.compactMap { resultDict -> RecognitionResult? in
                                    guard let alternatives = resultDict["alternatives"] as? [[String: Any]] else { return nil }
                                    
                                    let speechAlternatives = alternatives.compactMap { altDict -> SpeechAlternative? in
                                        guard let transcript = altDict["transcript"] as? String else { return nil }
                                        let confidence = altDict["confidence"] as? Float ?? 0.0
                                        return SpeechAlternative(transcript: transcript, confidence: confidence)
                                    }
                                    
                                    return RecognitionResult(alternatives: speechAlternatives)
                                }
                                
                                let sttResponse = STTResponse(results: recognitionResults)
                                continuation.resume(returning: sttResponse)
                            } else {
                                continuation.resume(throwing: SpeechRecognitionError.networkError("API 응답 형식 오류"))
                            }
                        } catch {
                            continuation.resume(throwing: SpeechRecognitionError.networkError("JSON 파싱 오류: \(error.localizedDescription)"))
                        }
                    }
                    
                case .failure(let moyaError):
                    continuation.resume(throwing: self.mapSTTMoyaError(moyaError))
                }
            }
        }
    }
    
    func textToSpeech(text: String) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.synthesizeSpeech(text: text, apiKey: apiKey)) { result in
                switch result {
                case .success(let response):
                    do {
                        // 1. Codable로 파싱 시도
                        let ttsResponse = try JSONDecoder().decode(TTSResponse.self, from: response.data)
                        
                        // Base64 디코딩하여 실제 오디오 데이터 반환
                        guard let audioData = Data(base64Encoded: ttsResponse.audioContent) else {
                            continuation.resume(throwing: TextToSpeechError.audioFormatError)
                            return
                        }
                        
                        print("TTS 성공 - 오디오 데이터 크기: \(audioData.count) bytes")
                        continuation.resume(returning: audioData)
                        
                    } catch {
                        // 2. 기존 방식으로 파싱 시도 (호환성)
                        do {
                            if let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any],
                               let audioContent = json["audioContent"] as? String {
                                
                                // Base64 디코딩하여 실제 오디오 데이터 반환
                                guard let audioData = Data(base64Encoded: audioContent) else {
                                    continuation.resume(throwing: TextToSpeechError.audioFormatError)
                                    return
                                }
                                
                                print("TTS 성공 (기존 파싱) - 오디오 데이터 크기: \(audioData.count) bytes")
                                continuation.resume(returning: audioData)
                                
                            } else {
                                continuation.resume(throwing: TextToSpeechError.networkError("TTS 응답 형식 오류"))
                            }
                        } catch {
                            continuation.resume(throwing: TextToSpeechError.networkError("TTS JSON 파싱 오류: \(error.localizedDescription)"))
                        }
                    }
                    
                case .failure(let moyaError):
                    continuation.resume(throwing: self.mapTTSMoyaError(moyaError))
                }
            }
        }
    }
    
    // MARK: - Error Mapping
    
    private func mapSTTMoyaError(_ error: MoyaError) -> SpeechRecognitionError {
        switch error {
        case .statusCode(let response):
            switch response.statusCode {
            case 400:
                return .audioFormatError
            case 401:
                return .apiKeyMissing
            case 403:
                return .networkError("API 키 권한이 없거나 할당량이 초과되었습니다")
            case 429:
                return .networkError("API 호출 한도를 초과했습니다. 잠시 후 다시 시도해주세요")
            case 500...599:
                return .networkError("Google 서버 오류가 발생했습니다")
            default:
                return .networkError("HTTP 오류: \(response.statusCode)")
            }
        case .jsonMapping:
            return .networkError("응답 데이터 형식이 올바르지 않습니다")
        case .requestMapping:
            return .networkError("요청 생성 중 오류가 발생했습니다")
        default:
            return .networkError("알 수 없는 오류: \(error.localizedDescription)")
        }
    }
    
    private func mapTTSMoyaError(_ error: MoyaError) -> TextToSpeechError {
        switch error {
        case .statusCode(let response):
            switch response.statusCode {
            case 400:
                return .audioFormatError
            case 401:
                return .apiKeyMissing
            case 403:
                return .networkError("API 키 권한이 없거나 할당량이 초과되었습니다")
            case 429:
                return .networkError("API 호출 한도를 초과했습니다. 잠시 후 다시 시도해주세요")
            case 500...599:
                return .networkError("Google 서버 오류가 발생했습니다")
            default:
                return .networkError("HTTP 오류: \(response.statusCode)")
            }
        case .jsonMapping:
            return .networkError("응답 데이터 형식이 올바르지 않습니다")
        case .requestMapping:
            return .networkError("요청 생성 중 오류가 발생했습니다")
        default:
            return .networkError("알 수 없는 오류: \(error.localizedDescription)")
        }
    }
}
