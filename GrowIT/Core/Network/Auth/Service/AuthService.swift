//
//  AuthService.swift
//  GrowIT
//
//  Created by 이수현 on 1/26/25.
//

import Foundation
import Moya

final class AuthService: NetworkManager {
    typealias Endpoint = AuthorizationEndpoints
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<AuthorizationEndpoints>
    
    public init(provider: MoyaProvider<AuthorizationEndpoints>? = nil) {
        // 플러그인 추가
        let plugins: [PluginType] = [
            // NetworkLoggerPlugin(configuration: .init(logOptions: [.requestMethod, .successResponseBody])), // 로그 플러그인
            AuthPlugin.shared
        ]
        
        // provider 초기화
        self.provider = provider ?? MoyaProvider<AuthorizationEndpoints>(plugins: plugins)
    }
    
    // MARK: - API funcs
    
    /// 이메일 인증 확인
    func verification(data: EmailVerifyRequest, completion: @escaping (Result<VerifyResponse, NetworkError>) -> Void) {
        request(target: .postVerification(data: data), decodingType: VerifyResponse.self, completion: completion)
    }
    
    // 소셜 간편 가입
    func signupWithKakao(oauthUserInfo: OauthUserInfo, userTerms: [UserTermDTO], completion: @escaping (Result<SocialSignUpResponse, Error>) -> Void) {
        let url = URL(string: "\(Constants.API.authURL)/signup/social")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userTermsArray = userTerms.map { ["termId": $0.termId, "agreed": $0.agreed] }
        
        let requestBody: [String: Any] = [
            "userTerms": userTermsArray,
            "oauthUserInfo": [
                "socialId": oauthUserInfo.socialId,
                "email": oauthUserInfo.email,
                "name": oauthUserInfo.name,
                "provider": oauthUserInfo.provider
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            // 서버 응답 데이터를 로그로 출력
            if let responseString = String(data: data, encoding: .utf8) {
                print("서버 응답 데이터: \(responseString)")
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let signupResponse = try JSONDecoder().decode(SocialSignUpResponse.self, from: data)
                    completion(.success(signupResponse))
                } catch {
                    completion(.failure(error))
                }
            } else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            }
        }
        
        task.resume()
    }
    
    
    // 카카오 소셜 로그인 API
    func postLoginKakao(data: SocialLoginRequest, completion: @escaping (Result<SocialLoginResponse, NetworkError>) -> Void) {
        provider.request(.postKakaoLogin(data: data)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(SocialLoginResponse.self, from: response.data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(.networkError(message: error.localizedDescription)))
            }
        }
    }
    
    // 애플 소셜 로그인 API
    func postLoginApple(data: SocialLoginRequest, completion: @escaping (Result<SocialLoginResponse, NetworkError>) -> Void) {
        provider.request(.postAppleLogin(data: data)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(SocialLoginResponse.self, from: response.data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(.networkError(message: error.localizedDescription)))
            }
        }
    }
    
    /// 이메일 로그인
    func loginEmail(data: EmailLoginRequest, completion: @escaping (Result<EmailLoginResponse, NetworkError>) -> Void) {
        provider.request(.postEmailLogin(data: data)) { result in
            switch result {
            case .success(let response):
                do {
                    let decodedResponse = try JSONDecoder().decode(EmailLoginResponse.self, from: response.data)
                    print("로그인 응답: \(decodedResponse)")
                    
                    completion(.success(decodedResponse))
                    
                } catch {
                    print("로그인 응답 디코딩 실패: \(error)")
                    completion(.failure(.decodingError))
                }
                
            case .failure(let error):
                print("네트워크 요청 실패: \(error.localizedDescription)")
                completion(.failure(.networkError(message: error.localizedDescription)))
            }
        }
    }
    
    
    /// 이메일 인증 요청
    func email(type: String, data: SendEmailVerifyRequest, completion: @escaping (Result<EmailVerifyResponse, NetworkError>) -> Void) {
        request(target: .postSendEmailVerification(type: type, data: data), decodingType: EmailVerifyResponse.self, completion: completion)
    }
    
    /// 회원가입 요청 (디코딩 오류 출력 추가)
    func signUp(type: String, data: EmailSignUpRequest, completion: @escaping (Result<EmailSignUpResponse, NetworkError>) -> Void) {
        provider.request(.postEmailSignUp(data: data)) { result in
            switch result {
            case .success(let response):
                do {
                    // 서버에서 받은 JSON 데이터 출력
                    let jsonString = String(data: response.data, encoding: .utf8)
                    print("서버 응답 JSON: \(jsonString ?? "데이터 없음")")
                    
                    // JSON 디코딩 시 오류 확인
                    let decodedResponse = try JSONDecoder().decode(EmailSignUpResponse.self, from: response.data)
                    print("회원가입 성공! 액세스 토큰")
                    
                    if let tokens = decodedResponse.result?.tokens {
                        TokenManager.shared.saveTokens(
                            accessToken: tokens.accessToken,
                            refreshToken: tokens.refreshToken
                        )
                        print("회원가입 후 토큰 저장 완료")
                    }
                    
                    completion(.success(decodedResponse))
                    
                } catch {
                    // 디코딩 오류 발생 시 상세 원인 출력
                    print("회원가입 응답 디코딩 실패: \(error)")
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, _):
                            print("키 없음: \(key.stringValue)")
                        case .typeMismatch(let type, let context):
                            print("타입 불일치: \(type), \(context.debugDescription)")
                        case .valueNotFound(let type, let context):
                            print("값 없음: \(type), \(context.debugDescription)")
                        default:
                            print("기타 디코딩 오류: \(error.localizedDescription)")
                        }
                    }
                    completion(.failure(.decodingError))
                }
                
            case .failure(let error):
                print("네트워크 요청 실패: \(error.localizedDescription)")
            }
        }
    }
    
    
    /// 토큰 재발급 요청 메서드
    func reissueToken(refreshToken: String, completion: @escaping (Result<ReissueResponse, NetworkError>) -> Void) {
        print("토큰 재발급 요청 시작 RefreshToken: \(refreshToken)")
        
        let request = ReissueTokenRequest(refreshToken: refreshToken)
        provider.request(.postReissueToken(data: request)) { result in
            switch result {
            case .success(let response):
                do {
                    let decodedResponse = try JSONDecoder().decode(ReissueResponse.self, from: response.data)
                    print("토큰 재발급 서버 응답 데이터: \(decodedResponse)")
                    
                    if decodedResponse.isSuccess {
                        print("토큰 재발급 성공! 새로운 AccessToken: \(decodedResponse.result.accessToken)")
                        
                        // AccessToken과 RefreshToken을 바로 저장
                        TokenManager.shared.saveAccessToken(decodedResponse.result.accessToken)
                        print("새로운 AccessToken 저장됨: \(decodedResponse.result.accessToken)")
                        
                        
                        completion(.success(decodedResponse))
                    } else {
                        print("토큰 재발급 실패: \(decodedResponse.message)")
                        completion(.failure(.serverError(statusCode: 400, message: decodedResponse.message)))
                    }
                    
                } catch {
                    print("토큰 재발급 응답 디코딩 실패: \(error)")
                    completion(.failure(.decodingError))
                }
                
            case .failure(let error):
                print("네트워크 요청 실패: \(error.localizedDescription)")
                completion(.failure(.networkError(message: error.localizedDescription)))
            }
        }
    }
    
    /// 로그아웃
    func postAuthLogout(completion: @escaping (Result<postLogoutResponseDTO, NetworkError>) -> Void) {
        request(
            target: .postLogout,
            decodingType: postLogoutResponseDTO.self,
            completion: completion
        )
    }
}

