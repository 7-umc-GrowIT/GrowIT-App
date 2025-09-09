//
//  AuthPlugin.swift
//  GrowIT
//
//  Created by 이수현 on 2/15/25.
//

import Foundation
import Moya
import UIKit
import Kingfisher

// 모든 API 요청에 Authorization 헤더를 추가하는 Moya 플러그인
final class AuthPlugin: PluginType {

    static let shared = AuthPlugin()
    private init() {}

    private var isRefreshing = false
    private var pendingRequests: [(TargetType, (Result<Response, MoyaError>) -> Void)] = []
    private let lock = NSLock()

    // MARK: - 요청 준비
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        if let authTarget = target as? AuthorizationEndpoints {
            switch authTarget {
            case .postEmailLogin, .postEmailSignUp, .postKakaoLogin,
                .postAppleLogin, .postSendEmailVerification, .postReissueToken:
                return request
            default: break
            }
        }
        if let token = TokenManager.shared.getAccessToken(), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    // MARK: - 응답 처리 (핵심 수정: completion 전달받기)
    func process(_ result: Result<Response, MoyaError>, target: TargetType, completion: @escaping (Result<Response, MoyaError>) -> Void) -> Result<Response, MoyaError> {
        switch result {
        case .success(let response) where response.statusCode == 401:
            enqueueRequest(target: target, completion: completion)
            refreshTokenIfNeeded()
            return result
        default:
            return result
        }
    }

    // MARK: - 큐에 요청 추가 (핵심: completion도 받음)
    public func enqueueRequest(target: TargetType, completion: @escaping (Result<Response, MoyaError>) -> Void) {
        lock.lock()
        pendingRequests.append((target, completion))
        lock.unlock()
    }

    // MARK: - 토큰 갱신 필요 시 실행
    public func refreshTokenIfNeeded() {
        lock.lock()
        let needRefresh = !isRefreshing
        print("refreshTokenIfNeeded called, needRefresh: \(needRefresh), isRefreshing: \(isRefreshing)")
        if needRefresh { isRefreshing = true }
        lock.unlock()

        guard needRefresh else { return }

        guard let refreshToken = TokenManager.shared.getRefreshToken() else {
            print("No refresh token found, forcing logout")
            DispatchQueue.main.async { self.forceLogout() }
            return
        }
        print("Attempting token refresh with refreshToken: \(refreshToken)")
        performTokenRefresh(refreshToken: refreshToken)
    }


    // MARK: - 토큰 갱신
    private func performTokenRefresh(refreshToken: String) {
        let provider = MoyaProvider<AuthorizationEndpoints>()
        let request = ReissueTokenRequest(refreshToken: refreshToken)
        provider.request(.postReissueToken(data: request)) { [weak self] result in
            guard let self = self else { return }
            self.lock.lock()
            self.isRefreshing = false
            let queued = self.pendingRequests
            self.pendingRequests.removeAll()
            self.lock.unlock()

            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(ReissueResponse.self, from: response.data)
                    if decoded.isSuccess {
                        TokenManager.shared.saveAccessToken(decoded.result.accessToken)
                        queued.forEach { target, callback in
                            self.retry(target: target, completion: callback)
                        }
                        return
                    }
                } catch {
                    print("디코딩 실패: \(error)")
                }
                self.failQueuedRequests(queued)

            case .failure(let error):
                print("갱신 실패: \(error)")
                self.failQueuedRequests(queued)
            }
        }
    }

    // MARK: - 재시도 (핵심: completion 전달)
    private func retry(target: TargetType, completion: @escaping (Result<Response, MoyaError>) -> Void) {
        if let authTarget = target as? AuthorizationEndpoints {
            let provider = MoyaProvider<AuthorizationEndpoints>(plugins: [AuthPlugin.shared])
            provider.request(authTarget, completion: completion)
        } else if let challengeTarget = target as? ChallengeEndpoint {
            let provider = MoyaProvider<ChallengeEndpoint>(plugins: [AuthPlugin.shared])
            provider.request(challengeTarget, completion: completion)
        } else if let diaryTarget = target as? DiaryEndpoint {
            let provider = MoyaProvider<DiaryEndpoint>(plugins: [AuthPlugin.shared])
            provider.request(diaryTarget, completion: completion)
        } else if let userTarget = target as? UserEndpoint {
            let provider = MoyaProvider<UserEndpoint>(plugins: [AuthPlugin.shared])
            provider.request(userTarget, completion: completion)
        } else if let groTarget = target as? GroEndpoint {
            let provider = MoyaProvider<GroEndpoint>(plugins: [AuthPlugin.shared])
            provider.request(groTarget, completion: completion)
        } else if let itemTarget = target as? ItemEndpoint {
            let provider = MoyaProvider<ItemEndpoint>(plugins: [AuthPlugin.shared])
            provider.request(itemTarget, completion: completion)
        } else if let termsTarget = target as? TermsEndpoints {
            let provider = MoyaProvider<TermsEndpoints>(plugins: [AuthPlugin.shared])
            provider.request(termsTarget, completion: completion)
        } else if let withdrawalTarget = target as? WithdrwalEndpoint {
            let provider = MoyaProvider<WithdrwalEndpoint>(plugins: [AuthPlugin.shared])
            provider.request(withdrawalTarget, completion: completion)
        } else {
            completion(.failure(MoyaError.underlying(
                NSError(domain: "AuthPlugin", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unsupported target"]),
                nil
            )))
        }
    }

//    private func retry(target: TargetType, completion: @escaping (Result<Response, MoyaError>) -> Void) {
//        switch target {
//        case let authTarget as AuthorizationEndpoints:
//            let provider = MoyaProvider<AuthorizationEndpoints>(plugins: [AuthPlugin.shared])
//            provider.request(authTarget, completion: completion)
//
//        case let challengeTarget as ChallengeEndpoint:
//            let provider = MoyaProvider<ChallengeEndpoint>(plugins: [AuthPlugin.shared])
//            provider.request(challengeTarget, completion: completion)
//
//        case let diaryTarget as DiaryEndpoint:
//            let provider = MoyaProvider<DiaryEndpoint>(plugins: [AuthPlugin.shared])
//            provider.request(diaryTarget, completion: completion)
//
//        case let userTarget as UserEndpoint:
//            let provider = MoyaProvider<UserEndpoint>(plugins: [AuthPlugin.shared])
//            provider.request(userTarget, completion: completion)
//
//        case let groTarget as GroEndpoint:
//            let provider = MoyaProvider<GroEndpoint>(plugins: [AuthPlugin.shared])
//            provider.request(groTarget, completion: completion)
//            
//        case let itemTarget as ItemEndpoint:
//            let provider = MoyaProvider<ItemEndpoint>(plugins: [AuthPlugin.shared])
//            provider.request(itemTarget, completion: completion)
//            
//        case let termsTarget as TermsEndpoints:
//            let provider = MoyaProvider<TermsEndpoints>(plugins: [AuthPlugin.shared])
//            provider.request(termsTarget, completion: completion)
//        
//        case let withDrawTarget as WithdrwalEndpoint:
//            let provider = MoyaProvider<WithdrwalEndpoint>(plugins: [AuthPlugin.shared])
//            provider.request(withDrawTarget, completion: completion)
//
//
//        default:
//            print("Unsupported target type: \(type(of: target))")
//            completion(.failure(MoyaError.underlying(
//                NSError(domain: "AuthPlugin", code: -1,
//                        userInfo: [NSLocalizedDescriptionKey: "Unsupported target type: \(type(of: target))"]),
//                nil)))
//        }
//    }


    private func failQueuedRequests(_ queued: [(TargetType, (Result<Response, MoyaError>) -> Void)]) {
        queued.forEach { _, callback in
            callback(.failure(MoyaError.underlying(
                NSError(domain: "AuthPlugin", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token refresh failed"]),
                nil
            )))
        }
        DispatchQueue.main.async { self.forceLogout() }
    }

    // MARK: - 강제 로그아웃
    private func forceLogout() {
        AppLaunchState.isFirstLaunch = true // 홈화면 첫 진입여부 초기화
        TokenManager.shared.clearTokens()
        GroImageCacheManager.shared.clearAll()
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache {
            print("🗑️ Kingfisher 디스크 캐시 초기화 완료")
        }

        let loginVC = MainLoginViewController()
        let nav = UINavigationController(rootViewController: loginVC)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
            UIView.transition(with: window,
                              duration: 0.1,
                              options: .transitionCrossDissolve,
                              animations: nil,
                              completion: nil)
        }
    }
}




//final class AuthPlugin: PluginType {
//    
//    private static var isRefreshing = false
//    private static var pendingRequests: [(TargetType, (Result<Response, MoyaError>) -> Void)] = []
//    private static let lock = NSLock()
//    
//    // MARK: - 요청 준비
//    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
//        var request = request
//        
//        // 로그인/회원가입 관련 API는 토큰 필요 없음
//        if let authTarget = target as? AuthorizationEndpoints {
//            switch authTarget {
//            case .postEmailLogin, .postEmailSignUp, .postKakaoLogin, .postAppleLogin, .postSendEmailVerification, .postReissueToken:
//                print("🚫 토큰 헤더 없이 요청: \(authTarget)")
//                return request
//            default:
//                break
//            }
//        }
//        
//        if let accessToken = TokenManager.shared.getAccessToken(), !accessToken.isEmpty {
//            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//            print("헤더에 AccessToken 추가됨")
//        } else {
//            print("저장된 AccessToken 없음")
//        }
//        
//        return request
//    }
//    
//    // MARK: - 응답 처리
//    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
//        print("🔍 AuthPlugin.process 호출됨 - Target: \(target)")
//        
//        switch result {
//        case .success(let response):
//            print("✅ 응답 수신 - Status: \(response.statusCode)")
//            if response.statusCode == 401 {
//                print("🔥 401 에러 감지됨! 토큰 갱신 로직 시작")
//                return handleUnauthorizedResponse(result: result, target: target)
//            }
//            return result
//        case .failure(let error):
//            print("❌ 네트워크 에러: \(error)")
//            return result
//        }
//    }
//    
//    private func handleUnauthorizedResponse(result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
//        print("🔍 handleUnauthorizedResponse 호출됨 - Target: \(target)")
//        
//        // AuthorizationEndpoints인 경우만 특별 처리
//        if let endpoint = target as? AuthorizationEndpoints {
//            // 로그인/회원가입/토큰갱신 관련 API는 토큰 처리 X
//            switch endpoint {
//            case .postEmailLogin, .postEmailSignUp, .postKakaoLogin, .postAppleLogin, .postSendEmailVerification, .postReissueToken:
//                print("⚠️ 로그인/회원가입/토큰갱신 API에서 401 → 토큰 갱신 스킵")
//                return result
//            default:
//                print("📝 AuthorizationEndpoints - 토큰 갱신 진행")
//                break
//            }
//        } else {
//            print("📝 다른 Endpoint (\(target)) - 토큰 갱신 진행")
//        }
//
//        guard let refreshToken = TokenManager.shared.getRefreshToken() else {
//            print("⚠️ RefreshToken 없음 → 자동 로그아웃 처리")
//            DispatchQueue.main.async {
//                self.forceLogout()
//            }
//            return result
//        }
//        
//        print("🔄 RefreshToken 존재 → 토큰 갱신 시작: \(refreshToken)")
//        return refreshTokenAndRetry(originalResult: result, target: target, refreshToken: refreshToken)
//    }
//    
//    private func refreshTokenAndRetry(originalResult: Result<Response, MoyaError>, target: TargetType, refreshToken: String) -> Result<Response, MoyaError> {
//        print("🔄 refreshTokenAndRetry 시작")
//        
//        AuthPlugin.lock.lock()
//        defer { AuthPlugin.lock.unlock() }
//        
//        if AuthPlugin.isRefreshing {
//            print("⏳ 이미 refresh 중 → 큐에 요청 추가")
//            return waitForRefreshCompletion(originalResult: originalResult, target: target)
//        }
//        
//        print("🚀 토큰 갱신 시작")
//        AuthPlugin.isRefreshing = true
//        return performTokenRefresh(originalResult: originalResult, target: target, refreshToken: refreshToken)
//    }
//    
//    private func waitForRefreshCompletion(originalResult: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
//        print("⏳ waitForRefreshCompletion 시작")
//        let semaphore = DispatchSemaphore(value: 0)
//        var finalResult: Result<Response, MoyaError> = originalResult
//        
//        // 큐에 요청 추가
//        AuthPlugin.pendingRequests.append((target, { result in
//            print("📥 큐에서 요청 완료: \(result)")
//            finalResult = result
//            semaphore.signal()
//        }))
//        
//        AuthPlugin.lock.unlock()
//        let waitResult = semaphore.wait(timeout: .now() + 1) // 10초 타임아웃
//        AuthPlugin.lock.lock()
//        
//        if waitResult == .timedOut {
//            print("⏰ 대기 시간 초과")
//        }
//        
//        return finalResult
//    }
//    
//    private func performTokenRefresh(originalResult: Result<Response, MoyaError>, target: TargetType, refreshToken: String) -> Result<Response, MoyaError> {
//        print("🚀 performTokenRefresh 시작")
//        let semaphore = DispatchSemaphore(value: 0)
//        var finalResult: Result<Response, MoyaError> = originalResult
//        
//        // 토큰 갱신을 위한 별도 provider (AuthPlugin 없이 - 무한루프 방지)
//        let refreshProvider = MoyaProvider<AuthorizationEndpoints>()
//        let refreshRequest = ReissueTokenRequest(refreshToken: refreshToken)
//        
//        print("📤 토큰 갱신 요청 전송 중... RefreshToken: \(refreshToken)")
//        refreshProvider.request(.postReissueToken(data: refreshRequest)) { reissueResult in
//            print("📥 토큰 갱신 응답 수신: \(reissueResult)")
//            
//            defer {
//                AuthPlugin.lock.lock()
//                AuthPlugin.isRefreshing = false
//                print("🔓 토큰 갱신 상태 해제")
//                AuthPlugin.lock.unlock()
//                semaphore.signal()
//            }
//            
//            switch reissueResult {
//            case .success(let reissueResponse):
//                print("✅ 토큰 갱신 응답 성공 - Status: \(reissueResponse.statusCode)")
//                
//                if let responseString = String(data: reissueResponse.data, encoding: .utf8) {
//                    print("📄 토큰 갱신 응답 내용: \(responseString)")
//                }
//                
//                do {
//                    let decodedResponse = try JSONDecoder().decode(ReissueResponse.self, from: reissueResponse.data)
//                    print("🔍 디코딩된 응답: \(decodedResponse)")
//                    
//                    if decodedResponse.isSuccess {
//                        let newAccessToken = decodedResponse.result.accessToken
//                        TokenManager.shared.saveAccessToken(newAccessToken)
//                        print("✅ AccessToken 갱신 완료: \(newAccessToken)")
//                        
//                        // 원래 요청 재시도
//                        print("🔄 원래 요청 재시도 시작")
//                        self.retryOriginalRequest(target: target) { retryResult in
//                            print("🔄 원래 요청 재시도 결과: \(retryResult)")
//                            finalResult = retryResult
//                        }
//                        
//                        // 대기 중인 요청들 처리
//                        self.processPendingRequests()
//                        
//                    } else {
//                        print("❌ 토큰 재발급 서버 실패: \(decodedResponse.message)")
//                        self.handleTokenRefreshFailure()
//                    }
//                } catch {
//                    print("❌ 토큰 재발급 디코딩 실패: \(error)")
//                    self.handleTokenRefreshFailure()
//                }
//                
//            case .failure(let error):
//                print("❌ 토큰 재발급 네트워크 실패: \(error)")
//                self.handleTokenRefreshFailure()
//            }
//        }
//        
//        print("⏳ 토큰 갱신 완료 대기 중...")
//        let waitResult = semaphore.wait(timeout: .now() + 1) // 10초 타임아웃
//        
//        if waitResult == .timedOut {
//            print("⏰ 토큰 갱신 타임아웃")
//        } else {
//            print("✅ 토큰 갱신 프로세스 완료")
//        }
//        
//        return finalResult
//    }
//    
//    private func retryOriginalRequest(target: TargetType, completion: @escaping (Result<Response, MoyaError>) -> Void) {
//        print("🔄 retryOriginalRequest 시작 - Target: \(target)")
//        
//        // AuthorizationEndpoints인 경우
//        if let authTarget = target as? AuthorizationEndpoints {
//            let retryProvider = MoyaProvider<AuthorizationEndpoints>(plugins: [AuthPlugin()])
//            retryProvider.request(authTarget, completion: completion)
//            return
//        }
//        
//        // ChallengeEndpoint인 경우 (Challenge API용)
//        if let challengeTarget = target as? ChallengeEndpoint {
//            let retryProvider = MoyaProvider<ChallengeEndpoint>(plugins: [AuthPlugin()])
//            retryProvider.request(challengeTarget, completion: completion)
//            return
//        }
//        
//        // 다른 엔드포인트 타입들도 필요에 따라 추가...
//        // 예: UserEndpoint, PostEndpoint 등
//        
//        print("❌ 지원되지 않는 target 타입: \(type(of: target))")
//        completion(.failure(MoyaError.underlying(NSError(domain: "AuthPlugin", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unsupported target type"]), nil)))
//    }
//    
//    private func processPendingRequests() {
//        print("🔄 processPendingRequests 시작")
//        AuthPlugin.lock.lock()
//        let queued = AuthPlugin.pendingRequests
//        AuthPlugin.pendingRequests.removeAll()
//        AuthPlugin.lock.unlock()
//        
//        print("📋 처리할 대기 요청 수: \(queued.count)")
//        
//        // 각 대기 중인 요청을 새 토큰으로 재시도
//        queued.forEach { (target, callback) in
//            print("🔄 대기 중이던 요청 재시도: \(target)")
//            retryOriginalRequest(target: target, completion: callback)
//        }
//    }
//    
//    private func handleTokenRefreshFailure() {
//        AuthPlugin.lock.lock()
//        let queued = AuthPlugin.pendingRequests
//        AuthPlugin.pendingRequests.removeAll()
//        AuthPlugin.lock.unlock()
//        
//        // 모든 대기 중인 요청에 실패 응답
//        queued.forEach { (_, callback) in
//            callback(.failure(MoyaError.underlying(NSError(domain: "AuthPlugin", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token refresh failed"]), nil)))
//        }
//        
//        // 강제 로그아웃
//        DispatchQueue.main.async {
//            self.forceLogout()
//        }
//    }
//    
//    // MARK: - 강제 로그아웃 처리
//    private func forceLogout() {
//        TokenManager.shared.clearTokens()
//        GroImageCacheManager.shared.clearAll()
//        ImageCache.default.clearMemoryCache()
//        ImageCache.default.clearDiskCache {
//            print("🗑️ Kingfisher 디스크 캐시 초기화 완료")
//        }
//
//        let loginVC = LoginViewController()
//        let nav = UINavigationController(rootViewController: loginVC)
//        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let window = scene.windows.first {
//            window.rootViewController = nav
//            window.makeKeyAndVisible()
//            UIView.transition(with: window,
//                              duration: 0.1,
//                              options: .transitionCrossDissolve,
//                              animations: nil,
//                              completion: nil)
//        }
//    }
//}
