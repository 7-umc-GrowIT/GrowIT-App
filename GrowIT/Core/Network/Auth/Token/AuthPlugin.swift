//
//  AuthPlugin.swift
//  GrowIT
//
//  Created by 이수현 on 2/15/25.
//

import Foundation
import Moya

/// 모든 API 요청에 자동으로 Authorization 헤더를 추가하는 Moya 플러그인
final class AuthPlugin: PluginType {
    
    private static var isRefreshing = false
    private static var pendingRequests: [(AuthorizationEndpoints, (Result<Response, MoyaError>) -> Void)] = []
    private let lock = NSLock()
    
    // MARK: - 요청 준비
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        
        // 로그인/회원가입 관련 API는 토큰 필요 없음
        if let authTarget = target as? AuthorizationEndpoints {
            switch authTarget {
            case .postEmailLogin, .postEmailSignUp, .postKakaoLogin, .postSendEmailVerification:
                return request
            default:
                break
            }
        }
        
        if let accessToken = TokenManager.shared.getAccessToken(), !accessToken.isEmpty {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            print("헤더에 AccessToken 추가됨")
        } else {
            print("저장된 AccessToken 없음")
        }
        
        return request
    }
    
    // MARK: - 응답 처리
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        switch result {
        case .success(let response) where response.statusCode == 401:
            guard let endpoint = target as? AuthorizationEndpoints else { return result }
            guard let refreshToken = TokenManager.shared.getRefreshToken() else {
                print("⚠️ RefreshToken 없음 → 자동 재발급 불가")
                return result
            }
            
            lock.lock()
            // 이미 다른 요청이 refresh 중이면, 큐에 대기
            if AuthPlugin.isRefreshing {
                print("⏳ 이미 refresh 중 → 큐에 요청 추가")
                AuthPlugin.pendingRequests.append((endpoint, { _ in }))
                lock.unlock()
                return result
            }
            
            // refresh 시작
            AuthPlugin.isRefreshing = true
            lock.unlock()
            
            let semaphore = DispatchSemaphore(value: 0)
            var finalResult: Result<Response, MoyaError> = result
            
            AuthService().reissueToken(refreshToken: refreshToken) { reissueResult in
                switch reissueResult {
                case .success(let reissueResponse):
                    let newAccessToken = reissueResponse.result.accessToken
                    TokenManager.shared.saveAccessToken(newAccessToken)
                    print("✅ AccessToken 갱신 완료")
                    
                    // 대기 중이던 요청 + 현재 요청 모두 재시도
                    self.lock.lock()
                    let queued = AuthPlugin.pendingRequests
                    AuthPlugin.pendingRequests.removeAll()
                    AuthPlugin.isRefreshing = false
                    self.lock.unlock()
                    
                    let provider = MoyaProvider<AuthorizationEndpoints>(plugins: [AuthPlugin()])
                    
                    // 현재 실패했던 요청 재시도
                    provider.request(endpoint) { retryResult in
                        finalResult = retryResult
                        semaphore.signal()
                    }
                    
                    // 큐에 쌓여 있던 요청 재시도
                    queued.forEach { (ep, callback) in
                        provider.request(ep) { retryResult in
                            callback(retryResult)
                        }
                    }
                    
                case .failure(let error):
                    print("❌ 토큰 재발급 실패: \(error)")
                    self.lock.lock()
                    AuthPlugin.pendingRequests.removeAll()
                    AuthPlugin.isRefreshing = false
                    self.lock.unlock()
                    semaphore.signal()
                }
            }
            
            _ = semaphore.wait(timeout: .now() + 5)
            return finalResult
            
        default:
            return result
        }
    }
}
