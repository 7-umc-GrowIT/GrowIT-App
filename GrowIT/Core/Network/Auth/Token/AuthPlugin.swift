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
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        
        // 로그인/회원가입 API는 토큰을 추가하지 않음
        if let authTarget = target as? AuthorizationEndpoints {
            switch authTarget {
            case .postEmailLogin, .postEmailSignUp, .postKakaoLogin, .postSendEmailVerification:
                return request
            default:
                break
            }
        }
        
        // 저장된 AccessToken 가져오기
        if let accessToken = TokenManager.shared.getAccessToken(), !accessToken.isEmpty {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            print("헤더에 AccessToken 추가됨")
        } else {
            print("저장된 AccessToken 없음")
        }
        
        return request
    }
    
    // 토큰 재발급
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
            switch result {
            case .success(let response):
                if response.statusCode == 401 {
                    guard let refreshToken = TokenManager.shared.getRefreshToken() else {
                        print("RefreshToken이 없음. 자동 재발급 불가.")
                        return result
                    }

                    let authService = AuthService()
                    authService.reissueToken(refreshToken: refreshToken) { reissueResult in
                        switch reissueResult {
                        case .success(let response):
                            let newAccessToken = response.result.accessToken
                            print("성공 새로운 AccessToken")

                            // 원래 요청을 다시 보낼 수 있도록 수정
                            if let originalRequest = target as? AuthorizationEndpoints {
                                MoyaProvider<AuthorizationEndpoints>().request(originalRequest) { retryResult in
                                    switch retryResult {
                                    case .success(let retryResponse):
                                        print("원래 요청 재시도 성공")
                                    case .failure(let error):
                                        print("요청 재시도 실패")
                                    }
                                }
                            } else {
                                print("실패")
                            }
                        case .failure(let error):
                            print("토큰 재발급 실패")
                        }
                    }
                }
            case .failure:
                break
            }
            return result
        }
}


