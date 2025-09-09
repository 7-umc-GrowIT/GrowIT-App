//
//  KakaoLoginHelper.swift
//  GrowIT
//
//  Created by 오현민 on 8/15/25.
//

import Foundation
import UIKit
import AuthenticationServices

final class KakaoLoginHelper: NSObject, ASWebAuthenticationPresentationContextProviding {
    
    // 토큰 요청 필요요소
    static var restApiKey: String {
        return Bundle.main.object(forInfoDictionaryKey: "REST_API_KEY") as? String ?? ""
    }
    
    static var urlScheme: String {
        return Bundle.main.object(forInfoDictionaryKey: "KAKAO_URLSCHEMES") as? String ?? ""
    }
    
    private var authSession: ASWebAuthenticationSession?
    
    // 인가 토큰 요청
    func getKakaoAuthorize(completion: @escaping (Result<String, Error>) -> Void) {
        let urlStr = """
           https://kauth.kakao.com/oauth/authorize?response_type=code
           &client_id=\(KakaoLoginHelper.restApiKey)
           &redirect_uri=\(KakaoLoginHelper.urlScheme)://oauth
           """
            .replacingOccurrences(of: "\n", with: "")
        
        guard let url = URL(string: urlStr) else { return }
        
        authSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: KakaoLoginHelper.urlScheme
        ) { callbackURL, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let callbackURL = callbackURL,
                  let comps = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                  let code = comps.queryItems?.first(where:  { $0.name == "code"})?.value else {
                completion(.failure(NSError(domain: "", code: -1)))
                return
            }
            completion(.success(code))
        }
        authSession?.presentationContextProvider = self
        authSession?.prefersEphemeralWebBrowserSession = false
        authSession?.start()
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.windows.first ?? ASPresentationAnchor()
    }
    
}
