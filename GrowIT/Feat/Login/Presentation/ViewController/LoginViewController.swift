//
//  LoginViewController.swift
//  GrowIT
//
//  Created by 강희정 on 1/13/25.
//

import UIKit
import Foundation
import SnapKit

class LoginViewController: UIViewController {
    
    let authService = AuthService()
    // 싱글톤 인스턴스 사용
    let kakaoLoginManager = KakaoLoginManager.shared
    
    private lazy var loginView = LoginView()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = loginView
        self.navigationController?.isNavigationBarHidden = true
        setupActions()
        //checkUserLoginStatus()
    }
    
    private func setupActions() {
        loginView.emailLoginButton.addTarget(self, action: #selector(emailLoginBtnTap), for: .touchUpInside)
        loginView.kakaoLoginButton.addTarget(self, action: #selector(kakaoLoginTapped), for: .touchUpInside)
    }
    
    
    //MARK: - Action
    
    // 뒤로 가기 버튼 함수
    @objc func emailLoginBtnTap() {
        let emailLoginVC = EmailLoginViewController()
        navigationController?.pushViewController(emailLoginVC, animated: true)
    }
    
    func navigateToEmailLogin() {
        let emailLoginVC = EmailLoginViewController()
        // EmailLoginViewController를 네비게이션 컨트롤러에서 푸시
        self.navigationController?.pushViewController(emailLoginVC, animated: true)
    }
    
    
    @objc func kakaoLoginTapped() {
        
        kakaoLoginManager.loginWithKakao { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let authCode):
                    self.handleKakaoLogin(with: authCode)
                    
                case .failure(let error):
                    print("카카오 로그인 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func handleKakaoLogin(with authCode: String) {
        authService.loginKakao(code: authCode) { [weak self] response in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                switch response {
                case .success(let loginResponse):
                    print("서버 로그인 성공: \(loginResponse)")
                    
                    if loginResponse.result.signupRequired {
                        guard let oauthUserInfo = loginResponse.result.oauthUserInfo else {
                            print("회원가입에 필요한 사용자 정보가 없습니다")
                            return
                        }
                        
                        let termsVC = KakaoTermsAgreeViewController(oauthUserInfo: oauthUserInfo)
                        termsVC.completionHandler = { [weak self] agreedTerms in
                            guard let self = self else { return }
                            
                            self.authService.signupWithKakao(
                                oauthUserInfo: oauthUserInfo,
                                userTerms: agreedTerms
                            ) { signupResponse in
                                DispatchQueue.main.async {
                                    switch signupResponse {
                                    case .success(let signupResult):
                                        
                                        if let tokens = signupResult.result.tokens {
                                            TokenManager.shared.saveTokens(
                                                accessToken: tokens.accessToken,
                                                refreshToken: tokens.refreshToken
                                            )
                                            self.navigateToMainScreen()
                                        } else {
                                            print("회원가입 후에도 토큰이 없음")
                                        }
                                        
                                    case .failure(let error):
                                        print("회원가입 실패: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                        self.navigationController?.pushViewController(termsVC, animated: true)
                    } else {
                        print("로그인 성공 토큰 저장")
                        
                        if let tokens = loginResponse.result.tokens {
                            TokenManager.shared.saveTokens(
                                accessToken: tokens.accessToken,
                                refreshToken: tokens.refreshToken
                            )
                            self.navigateToMainScreen()
                        } else {
                            print("로그인 성공했지만 토큰이 없음, 추가 확인 필요")
                        }
                    }
                    
                case .failure(let error):
                    print("서버 로그인 실패: \(error.localizedDescription)")
                    
                    if error.localizedDescription.contains("인가 코드가 유효한지 확인하세요") {
                        print("인가 코드 만료됨 retry")
                        self.retryKakaoLogin()
                    }
                }
            }
        }
    }
    
    // 인가 코드가 만료되었을 때 다시 로그인하는 함수 추가
    private func retryKakaoLogin() {
        kakaoLoginManager.loginWithKakao { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let newAuthCode):
                    print("새로운 인가 코드 획득: \(newAuthCode)")
                    self.handleKakaoLogin(with: newAuthCode)
                    
                case .failure(let error):
                    print("카카오 로그인 재시도 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func checkUserLoginStatus() {
        if let accessToken = TokenManager.shared.getAccessToken() {
            print("기존 로그인 정보 확인됨 accessToken: \(accessToken)")
            navigateToMainScreen()
        } else {
            print("로그인 정보 없음")
        }
    }
    
    private func navigateToMainScreen() {
        let homeVC = HomeViewController()
        // 현재 네비게이션 컨트롤러의 뷰 컨트롤러 스택을 교체
        navigationController?.setViewControllers([homeVC], animated: true)
    }
    
}
