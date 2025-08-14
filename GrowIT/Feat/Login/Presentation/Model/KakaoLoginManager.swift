//
//  KakaoLoginManager.swift
//  GrowIT
//
//  Created by 강희정 on 1/30/25.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon
import UIKit

final class KakaoLoginManager {
    static let shared = KakaoLoginManager()
    
    private init() {}
    
    private var completionHandler: ((Result<String, Error>) -> Void)?
    
    // OAuth 설정
    private let clientId = "ad38f7a54ae0b83d104d8fcb239aebea"
    private let redirectUri = "kakaoad38f7a54ae0b83d104d8fcb239aebea://oauth"
    
    func loginWithKakao(completion: @escaping (Result<String, Error>) -> Void) {
        print("KakaoLoginManager: loginWithKakao 시작")
        self.completionHandler = completion
        
        // 카카오톡 설치 여부 확인
        if UserApi.isKakaoTalkLoginAvailable() {
            loginWithKakaoTalk()
        } else {
            loginWithKakaoAccount()
        }
    }
    
    private func loginWithKakaoTalk() {
        print("KakaoLoginManager: 카카오톡 로그인 시도")
        
        UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("카카오톡 로그인 실패: \(error.localizedDescription)")
                self.requestAuthorizationCode()
                return
            }
            
            // 카카오톡 로그인 성공 후 인증 코드 요청
            print("KakaoLoginManager: 카카오톡 로그인 성공, 인증 코드 요청")
            self.requestAuthorizationCode()
        }
    }
    
    private func loginWithKakaoAccount() {
        print("KakaoLoginManager: 카카오 계정 로그인 시도")
        
        UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ 카카오 계정 로그인 실패: \(error.localizedDescription)")
                self.requestAuthorizationCode()
                return
            }
            
            // 카카오 계정 로그인 성공 후 인증 코드 요청
            print("KakaoLoginManager: 카카오 계정 로그인 성공, 인증 코드 요청")
            self.requestAuthorizationCode()
        }
    }
    
    private func requestAuthorizationCode() {
        // 인증 코드 요청 URL 생성
        var components = URLComponents(string: "https://kauth.kakao.com/oauth/authorize")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "response_type", value: "code")
        ]
        
        guard let url = components.url else {
            print("KakaoLoginManager: 인증 URL 생성 실패")
            self.completionHandler?(.failure(NSError(domain: "", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create authorization URL"])))
            self.completionHandler = nil
            return
        }
        
        print("KakaoLoginManager: 인증 코드 요청 URL 생성됨: \(url)")
        
        DispatchQueue.main.async {
            UIApplication.shared.open(url) { success in
                if !success {
                    print("KakaoLoginManager: URL 열기 실패")
                    self.completionHandler?(.failure(NSError(domain: "", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to open authorization URL"])))
                    self.completionHandler = nil
                }
            }
        }
    }
    
    func handleAuthorizationCode(from url: URL) {
        print("KakaoLoginManager: handleAuthorizationCode 시작")
        print("URL 받음: \(url)")
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("KakaoLoginManager: URL 컴포넌트 파싱 실패")
            self.completionHandler?(.failure(NSError(domain: "", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to parse URL"])))
            self.completionHandler = nil
            return
        }
        
        guard let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            print("KakaoLoginManager: 인가 코드를 찾을 수 없음")
            self.completionHandler?(.failure(NSError(domain: "", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Authorization code not found"])))
            self.completionHandler = nil
            return
        }
        
        print("KakaoLoginManager: 인가 코드 획득 성공: \(code)")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                print("KakaoLoginManager: self is nil")
                return
            }
            
            if let handler = self.completionHandler {
                print("KakaoLoginManager: completionHandler 호출")
                handler(.success(code))
            } else {
                print("KakaoLoginManager: completionHandler is nil")
            }
            
            self.completionHandler = nil
        }
    }
}
