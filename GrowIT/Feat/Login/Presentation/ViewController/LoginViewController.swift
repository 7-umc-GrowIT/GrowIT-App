//
//  LoginViewController.swift
//  GrowIT
//
//  Created by 강희정 on 1/13/25.
//

import UIKit
import Foundation
import SnapKit
import AuthenticationServices

class LoginViewController: UIViewController {
    
    let authService = AuthService()
    private lazy var kakaoLoginHelper = KakaoLoginHelper()
    
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
    }
    
    private func setupActions() {
        loginView.emailLoginButton.addTarget(self, action: #selector(emailLoginBtnTap), for: .touchUpInside)
        loginView.kakaoLoginButton.addTarget(self, action: #selector(kakaoLoginTapped), for: .touchUpInside)
        loginView.appleLoginButton.addTarget(self, action: #selector(appleLoginTapped), for: .touchUpInside)
    }
    
    
    //MARK: - Action
    
    func navigateToEmailLogin() {
        let emailLoginVC = EmailLoginViewController()
        // EmailLoginViewController를 네비게이션 컨트롤러에서 푸시
        self.navigationController?.pushViewController(emailLoginVC, animated: true)
    }
    
    // 이메일 로그인 버튼
    @objc
    func emailLoginBtnTap() {
        let emailLoginVC = EmailLoginViewController()
        navigationController?.pushViewController(emailLoginVC, animated: true)
    }
    
    // 카카오 로그인 버튼
    @objc
    func kakaoLoginTapped() {
        // 1. 카카오 인가 코드 요청
        kakaoLoginHelper.getKakaoAuthorize { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let code):
                // 2. 서버 로그인 요청
                self.loginWithServer(code)
            case .failure(let error):
                print("카카오 로그인 실패: \(error.localizedDescription)")
            }
        }
    }

    // 애플 로그인 버튼
    @objc
    func appleLoginTapped() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    // MARK: - 서버 요청 로직
    // 인가 코드를 서버에 전달하여 로그인 요청
    private func loginWithServer(_ code: String) {
        authService.loginKakao(code: code) { [weak self] response in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch response {
                case .success(let loginResponse):
                    print("🌳 그로우잇 서버 로그인 성공: \(loginResponse)")
                    self.handleLoginResponse(loginResponse)
                case .failure(let error):
                    print("서버 로그인 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    /// 로그인 응답 처리
    /// - 회원가입이 필요한 경우: 약관 동의 화면으로 이동
    /// - 회원가입 불필요: 토큰 저장 후 메인 화면 이동
    private func handleLoginResponse(_ loginResponse: KakaoLoginResponse) {
        if loginResponse.result.signupRequired {
            // 회원가입 필요 (true)
            showTermsAgree(oauthUserInfo: loginResponse.result.oauthUserInfo)
        } else {
            // 회원가입 불필요 → 바로 로그인 완료 처리, 토큰 저장 (false)
            saveTokensAndNavigate(
                accessToken: loginResponse.result.tokens?.accessToken,
                refreshToken: loginResponse.result.tokens?.refreshToken
            )
        }
    }

    /// 약관 동의 화면 표시
    private func showTermsAgree(oauthUserInfo: KakaoUserInfo?) {
        guard let oauthUserInfo = oauthUserInfo else {
            print("회원가입에 필요한 사용자 정보가 없습니다")
            return
        }
        
        let termsVC = KakaoTermsAgreeViewController(oauthUserInfo: oauthUserInfo)
        termsVC.completionHandler = { [weak self] agreedTerms in
            guard let self = self else { return }
            self.signupWithKakao(oauthUserInfo: oauthUserInfo, userTerms: agreedTerms)
        }
        navigationController?.pushViewController(termsVC, animated: true)
    }

    /// 회원가입 요청
    private func signupWithKakao(oauthUserInfo: KakaoUserInfo, userTerms: [UserTermDTO]) {
        authService.signupWithKakao(oauthUserInfo: oauthUserInfo, userTerms: userTerms) { [weak self] signupResponse in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch signupResponse {
                case .success(let signupResult):
                    // 토큰 저장
                    TokenManager.shared.saveTokens(
                        accessToken: signupResult.result.accessToken,
                        refreshToken: signupResult.result.refreshToken
                    )
                    // 그로 생성 화면으로 이동
                    self.navigateToGroCreation()
                case .failure(let error):
                    print("회원가입 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    /// 토큰 저장 후 메인 화면 이동
    private func saveTokensAndNavigate(accessToken: String?, refreshToken: String?) {
        guard let accessToken = accessToken, let refreshToken = refreshToken else {
            print("토큰이 없습니다")
            return
        }
        
        TokenManager.shared.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
        navigateToMainScreen()
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
        let tabBar = CustomTabBarController(initialIndex: 1)
        let nav = UINavigationController(rootViewController: tabBar)
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        } else {
            // 폴백: 현재 내비 스택 교체
            navigationController?.setViewControllers([tabBar], animated: true)
        }
    }
    
    private func navigateToGroCreation() {
        let groCreationVC = GroSetBackgroundViewController()
        navigationController?.pushViewController(groCreationVC, animated: true)
    }
    
}

// MARK: - extension
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    // 인증창을 보여주기 위한 메서드 (인증창을 보여 줄 화면을 설정)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.view.window ?? UIWindow()
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    // 로그인 실패 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        print("로그인 실패", error.localizedDescription)
    }
    
    // Apple ID 로그인에 성공한 경우, 사용자의 인증 정보를 확인하고 필요한 작업을 수행합니다
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            
            guard let authorizationCodeData = appleIdCredential.authorizationCode,
                  let authorizationCodeString = String(data: authorizationCodeData, encoding: .utf8) else {
                print("Authorization Code 변환 실패")
                return
            }
            
            print("Apple ID 로그인에 성공하였습니다.")
            print("authorizationCode: \(authorizationCodeString)")
            
            // 여기에 로그인 성공 후 수행할 작업을 추가하세요.
            
            
        default: break
            
        }
    }
}
