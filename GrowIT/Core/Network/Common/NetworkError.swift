//
//  NetworkError.swift
//  GrowIT
//
//  Created by 이수현 on 1/20/25.
//

import Foundation

public enum NetworkError: Error {
    case networkError(message: String)
    case decodingError
    case serverError(statusCode: Int, message: String)
    case unknown
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "네트워크 오류: \(message)"
        case .decodingError:
            return "데이터 디코딩에 실패했습니다."
        case .serverError(let statusCode, let message):
            return "[오류 \(statusCode)] \(message)"
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}


public struct ErrorResponse: Decodable {
    let message: String
}
