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
    // 이메일 회원가입 API
    func postAuthSignUp(type: String, data: AuthSignUpRequestDTO, completion: @escaping (Result<AuthSignUpResponseDTO, NetworkError>) -> Void) {
        provider.request(.postSignUp(data: data)) { result in
            switch result {
            case .success(let response):
                do {
                    // 서버에서 받은 JSON 데이터 출력
                    let jsonString = String(data: response.data, encoding: .utf8)
                    print("서버 응답 JSON: \(jsonString ?? "데이터 없음")")
                    
                    // JSON 디코딩 시 오류 확인
                    let decodedResponse = try JSONDecoder().decode(AuthSignUpResponseDTO.self, from: response.data)
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
    
    // 소셜 간편 가입 API
    func postAuthSocialSignUp(oauthUserInfo: OauthUserInfo, userTerms: [UserTermDTO], completion: @escaping (Result<AuthSignUpSocialResponseDTO, Error>) -> Void) {
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
                    let signupResponse = try JSONDecoder().decode(AuthSignUpSocialResponseDTO.self, from: data)
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
    
    // 토큰 재발급 API
    func postAuthReissueToken(refreshToken: String, completion: @escaping (Result<AuthReissueResponseDTO, NetworkError>) -> Void) {
        print("토큰 재발급 요청 시작 RefreshToken: \(refreshToken)")
        
        let request = AuthReissueRequestDTO(refreshToken: refreshToken)
        provider.request(.postReissueToken(data: request)) { result in
            switch result {
            case .success(let response):
                do {
                    let decodedResponse = try JSONDecoder().decode(AuthReissueResponseDTO.self, from: response.data)
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
    
    // 이메일 로그인 API
    func loginEmail(data: AuthLoginRequestDTO, completion: @escaping (Result<AuthLoginResponseDTO, NetworkError>) -> Void) {
        provider.request(.postLogin(data: data)) { result in
            switch result {
            case .success(let response):
                do {
                    let decodedResponse = try JSONDecoder().decode(AuthLoginResponseDTO.self, from: response.data)
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
    
    // 카카오 로그인 API
    func postLoginKakao(data: AuthLoginSocialRequestDTO, completion: @escaping (Result<AuthLoginSocialResponsetDTO, NetworkError>) -> Void) {
        provider.request(.postLoginKakao(data: data)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(AuthLoginSocialResponsetDTO.self, from: response.data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(.networkError(message: error.localizedDescription)))
            }
        }
    }
    
    // 애플 로그인 API
    func postLoginApple(data: AuthLoginSocialRequestDTO, completion: @escaping (Result<AuthLoginSocialResponsetDTO, NetworkError>) -> Void) {
        provider.request(.postLoginApple(data: data)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(AuthLoginSocialResponsetDTO.self, from: response.data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(.networkError(message: error.localizedDescription)))
            }
        }
    }
    
    // 인증번호 검증 API
    func verification(
        data: AuthEmailVerifyRequestDTO,
        completion: @escaping (Result<AuthEmailVerifyResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .postEmailVerify(data: data),
            decodingType: AuthEmailVerifyResponseDTO.self,
            completion: completion
        )
    }
    
    // 인증 이메일 발송 API
    func email(
        type: String,
        data: AuthEmailSendReqeustDTO,
        completion: @escaping (Result<AuthEmailSendResponseDTO, NetworkError>) -> Void) {
            request(
                target: .postEmailSend(type: type, data: data),
                decodingType: AuthEmailSendResponseDTO.self,
                completion: completion
            )
        }
    
    // 로그아웃 API
    func postAuthLogout(completion: @escaping (Result<postLogoutResponseDTO, NetworkError>) -> Void) {
        request(
            target: .postLogout,
            decodingType: postLogoutResponseDTO.self,
            completion: completion
        )
    }
}
