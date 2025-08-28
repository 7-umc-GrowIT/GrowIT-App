//
//  TextToSpeechError.swift
//  GrowIT
//
//  Created by 허준호 on 8/16/25.
//

enum TextToSpeechError: Error {
    case noResults
    case apiKeyMissing
    case networkError(String)
    case audioFormatError
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .noResults:
            return "음성 합성 결과가 없습니다"
        case .apiKeyMissing:
            return "API 키가 설정되지 않았거나 유효하지 않습니다"
        case .networkError(let message):
            return message
        case .audioFormatError:
            return "오디오 형식 오류가 발생했습니다"
        case .unknownError:
            return "알 수 없는 오류가 발생했습니다"
        }
    }
}
