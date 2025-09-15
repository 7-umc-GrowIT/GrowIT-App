//
//  TokenManager.swift
//  GrowIT
//
//  Created by 강희정 on 2/1/25.
//

import Security
import Foundation
import Moya

extension NetworkManager {
    // ✅ 1. 필수 데이터 요청
    func request<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                if response.statusCode == 401 {
                    // 401 에러 별도 처리 - 토큰갱신 및 재요청 요청
                    AuthPlugin.shared.enqueueRequest(target: target) { retryResult in
                        switch retryResult {
                        case .success(let retryResponse):
                            let handled = handleResponse(retryResponse, decodingType: decodingType)
                            completion(handled)
                        case .failure(let error):
                            completion(.failure(.networkError(message: error.localizedDescription)))
                        }
                    }
                    AuthPlugin.shared.refreshTokenIfNeeded()
                } else {
                    let handled = handleResponse(response, decodingType: decodingType)
                    completion(handled)
                }
            case .failure(let error):
                completion(.failure(handleNetworkError(error)))
            }
        }
    }
    
    
    // ✅ 2. 옵셔널 데이터 요청
    func requestOptional<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T?, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                if response.statusCode == 401 {
                    AuthPlugin.shared.enqueueRequest(target: target) { retryResult in
                        switch retryResult {
                        case .success(let retryResponse):
                            let handled = handleResponseOptional(retryResponse, decodingType: decodingType)
                            completion(handled)
                        case .failure(let error):
                            completion(.failure(.networkError(message: error.localizedDescription)))
                        }
                    }
                    AuthPlugin.shared.refreshTokenIfNeeded()
                } else {
                    let handled = handleResponseOptional(response, decodingType: decodingType)
                    completion(handled)
                }
            case .failure(let error):
                completion(.failure(handleNetworkError(error)))
            }
        }
    }
    
    
    // ✅ 3. 상태 코드만 확인
    func requestStatusCode(
        target: Endpoint,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                if response.statusCode == 401 {
                    AuthPlugin.shared.enqueueRequest(target: target) { retryResult in
                        switch retryResult {
                        case .success(let retryResponse):
                            let handled: Result<ApiResponse<String?>?, NetworkError> = handleResponseOptional(
                                retryResponse,
                                decodingType: ApiResponse<String?>.self
                            )
                            switch handled {
                            case .success:
                                completion(.success(()))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        case .failure(let error):
                            completion(.failure(.networkError(message: error.localizedDescription)))
                        }
                    }
                    AuthPlugin.shared.refreshTokenIfNeeded()
                } else {
                    let handled: Result<ApiResponse<String?>?, NetworkError> = handleResponseOptional(
                        response,
                        decodingType: ApiResponse<String?>.self
                    )
                    switch handled {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(handleNetworkError(error)))
            }
        }
    }
    
    
    // ✅ 4. 유효기간 파싱 + 데이터 파싱
    func requestWithTime<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<(T, TimeInterval?), NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                if response.statusCode == 401 {
                    AuthPlugin.shared.enqueueRequest(target: target) { retryResult in
                        switch retryResult {
                        case .success(let retryResponse):
                            let handled: Result<(T, TimeInterval?), NetworkError> = handleResponseTimeInterval(
                                retryResponse,
                                decodingType: decodingType
                            )
                            completion(handled)
                        case .failure(let error):
                            completion(.failure(.networkError(message: error.localizedDescription)))
                        }
                    }
                    AuthPlugin.shared.refreshTokenIfNeeded()
                } else {
                    let handled: Result<(T, TimeInterval?), NetworkError> = handleResponseTimeInterval(
                        response,
                        decodingType: decodingType
                    )
                    completion(handled)
                }
            case .failure(let error):
                completion(.failure(handleNetworkError(error)))
            }
        }
    }
}
    
// MARK: - 상태 코드 처리 헬퍼들
fileprivate func handleResponse<T: Decodable>(
    _ response: Response,
    decodingType: T.Type
) -> Result<T, NetworkError> {
    do {
        print("🔍 handleResponse 호출됨 - Status: \(response.statusCode)")
        
        guard (200...299).contains(response.statusCode) else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
            let message = errorResponse?.message ?? "HTTP \(response.statusCode)"
            return .failure(.serverError(statusCode: response.statusCode, message: message))
        }
        
        // ✅ result 없는 경우 VerifyResponse 직접 디코딩 허용
        if T.self == AuthEmailVerifyResponseDTO.self {
            let decoded = try JSONDecoder().decode(AuthEmailVerifyResponseDTO.self, from: response.data)
            return .success(decoded as! T)
        }
        
        let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)
        
        if let result = apiResponse.result {
            return .success(result)
        } else {
            // ✅ 빈 객체 {} 도 성공으로 처리
            if let emptyDecoded = try? JSONDecoder().decode(T.self, from: "{}".data(using: .utf8)!) {
                return .success(emptyDecoded)
            }
            
            if T.self == EmptyResponse.self || T.self == EmptyResult.self {
                return .success(EmptyResult() as! T)
            }
            
            return .failure(.serverError(statusCode: response.statusCode, message: "결과 없음"))
        }
    } catch {
        return .failure(.decodingError)
    }
}

fileprivate func handleResponseOptional<T: Decodable>(
    _ response: Response,
    decodingType: T.Type
) -> Result<T?, NetworkError> {
    do {
        print("🔍 handleResponseOptional 호출됨 - Status: \(response.statusCode)")
        
        guard (200...299).contains(response.statusCode) else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
            let message = errorResponse?.message ?? "HTTP \(response.statusCode)"
            return .failure(.serverError(statusCode: response.statusCode, message: message))
        }
        
        if response.data.isEmpty { return .success(nil) }
        let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)
        return .success(apiResponse.result)
    } catch {
        return .failure(.decodingError)
    }
}

fileprivate func handleResponseTimeInterval<T: Decodable>(
    _ response: Response,
    decodingType: T.Type
) -> Result<(T, TimeInterval?), NetworkError> {
    do {
        print("🔍 handleResponseTimeInterval 호출됨 - Status: \(response.statusCode)")
        
        guard (200...299).contains(response.statusCode) else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
            let message = errorResponse?.message ?? "HTTP \(response.statusCode)"
            return .failure(.serverError(statusCode: response.statusCode, message: message))
        }
        
        let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)
        guard let result = apiResponse.result else {
            return .failure(.serverError(statusCode: response.statusCode, message: "결과 없음"))
        }
        return .success((result, nil))
    } catch {
        return .failure(.decodingError)
    }
}

// 네트워크 오류 핸들링
fileprivate func handleNetworkError(_ error: Error) -> NetworkError {
    let nsError = error as NSError
    switch nsError.code {
    case NSURLErrorNotConnectedToInternet:
        return .networkError(message: "인터넷 연결이 끊겼습니다.")
    case NSURLErrorTimedOut:
        return .networkError(message: "요청 시간이 초과되었습니다.")
    default:
        return .networkError(message: "네트워크 오류가 발생했습니다.")
    }
}
