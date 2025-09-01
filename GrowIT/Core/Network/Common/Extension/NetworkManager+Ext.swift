//
//  NetworkManager+Ext.swift
//  GrowIT
//
//  Created by 이수현 on 1/20/25.
//

import Moya
import Foundation

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
                    self.handleTokenRefreshAndRetry(target: target, decodingType: decodingType, completion: completion)
                } else {
                    let result: Result<T, NetworkError> = handleResponse(response, decodingType: decodingType)
                    completion(result)
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
                    self.handleTokenRefreshAndRetryOptional(target: target, decodingType: decodingType, completion: completion)
                } else {
                    let result: Result<T?, NetworkError> = handleResponseOptional(response, decodingType: decodingType)
                    completion(result)
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
                    self.handleTokenRefreshAndRetryStatusCode(target: target, completion: completion)
                } else {
                    let result: Result<ApiResponse<String?>?, NetworkError> = handleResponseOptional(
                        response,
                        decodingType: ApiResponse<String?>.self
                    )
                    switch result {
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
                    self.handleTokenRefreshAndRetryWithTime(target: target, decodingType: decodingType, completion: completion)
                } else {
                    let result: Result<(T, TimeInterval?), NetworkError> = handleResponseTimeInterval(response, decodingType: decodingType)
                    completion(result)
                }
            case .failure(let error):
                completion(.failure(handleNetworkError(error)))
            }
        }
    }
    
    // MARK: - 401 처리 공통 로직
    private func handleTokenRefreshAndRetry<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let refreshToken = TokenManager.shared.getRefreshToken() else {
            completion(.failure(.serverError(statusCode: 401, message: "Unauthorized")))
            return
        }
        AuthService().reissueToken(refreshToken: refreshToken) { reissueResult in
            switch reissueResult {
            case .success(let reissueResponse):
                TokenManager.shared.saveAccessToken(reissueResponse.result.accessToken)
                print("✅ AccessToken 재발급 완료, 요청 재시도")
                self.provider.request(target) { retryResult in
                    switch retryResult {
                    case .success(let retryResponse):
                        let result: Result<T, NetworkError> = handleResponse(retryResponse, decodingType: decodingType)
                        completion(result)
                    case .failure(let error):
                        completion(.failure(handleNetworkError(error)))
                    }
                }
            case .failure:
                completion(.failure(.serverError(statusCode: 401, message: "Unauthorized")))
            }
        }
    }
    
    private func handleTokenRefreshAndRetryOptional<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T?, NetworkError>) -> Void
    ) {
        guard let refreshToken = TokenManager.shared.getRefreshToken() else {
            completion(.failure(.serverError(statusCode: 401, message: "Unauthorized")))
            return
        }
        AuthService().reissueToken(refreshToken: refreshToken) { reissueResult in
            switch reissueResult {
            case .success(let reissueResponse):
                TokenManager.shared.saveAccessToken(reissueResponse.result.accessToken)
                print("✅ AccessToken 재발급 완료, 요청 재시도")
                self.provider.request(target) { retryResult in
                    switch retryResult {
                    case .success(let retryResponse):
                        let result: Result<T?, NetworkError> = handleResponseOptional(retryResponse, decodingType: decodingType)
                        completion(result)
                    case .failure(let error):
                        completion(.failure(handleNetworkError(error)))
                    }
                }
            case .failure:
                completion(.failure(.serverError(statusCode: 401, message: "Unauthorized")))
            }
        }
    }
    
    private func handleTokenRefreshAndRetryStatusCode(
        target: Endpoint,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        guard let refreshToken = TokenManager.shared.getRefreshToken() else {
            completion(.failure(.serverError(statusCode: 401, message: "Unauthorized")))
            return
        }
        AuthService().reissueToken(refreshToken: refreshToken) { reissueResult in
            switch reissueResult {
            case .success(let reissueResponse):
                TokenManager.shared.saveAccessToken(reissueResponse.result.accessToken)
                print("✅ AccessToken 재발급 완료, 요청 재시도")
                self.provider.request(target) { retryResult in
                    switch retryResult {
                    case .success(let retryResponse):
                        let result: Result<ApiResponse<String?>?, NetworkError> = handleResponseOptional(
                            retryResponse,
                            decodingType: ApiResponse<String?>.self
                        )
                        switch result {
                        case .success:
                            completion(.success(()))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    case .failure(let error):
                        completion(.failure(handleNetworkError(error)))
                    }
                }
            case .failure:
                completion(.failure(.serverError(statusCode: 401, message: "Unauthorized")))
            }
        }
    }
    
    private func handleTokenRefreshAndRetryWithTime<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<(T, TimeInterval?), NetworkError>) -> Void
    ) {
        guard let refreshToken = TokenManager.shared.getRefreshToken() else {
            completion(.failure(.serverError(statusCode: 401, message: "Unauthorized")))
            return
        }
        AuthService().reissueToken(refreshToken: refreshToken) { reissueResult in
            switch reissueResult {
            case .success(let reissueResponse):
                TokenManager.shared.saveAccessToken(reissueResponse.result.accessToken)
                print("✅ AccessToken 재발급 완료, 요청 재시도")
                self.provider.request(target) { retryResult in
                    switch retryResult {
                    case .success(let retryResponse):
                        let result: Result<(T, TimeInterval?), NetworkError> = handleResponseTimeInterval(retryResponse, decodingType: decodingType)
                        completion(result)
                    case .failure(let error):
                        completion(.failure(handleNetworkError(error)))
                    }
                }
            case .failure:
                completion(.failure(.serverError(statusCode: 401, message: "Unauthorized")))
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
        guard (200...299).contains(response.statusCode) else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
            let message = errorResponse?.message ?? "HTTP \(response.statusCode)"
            return .failure(.serverError(statusCode: response.statusCode, message: message))
        }
        let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)
        
        // ✅ result가 없어도 성공 처리할 수 있게 분기
        if let result = apiResponse.result {
            return .success(result)
        } else if T.self == EmptyResult.self {
            // result 없는 경우 → EmptyResult() 로 success 반환
            return .success(EmptyResult() as! T)
        } else {
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

// 맨 아래에 추가
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

