//
//  EmailVerificationViewController.swift
//  GrowIT
//
//  Created by 강희정 on 1/25/25.
//

import UIKit
import Foundation

class EmailVerificationViewController: UIViewController {
    // MARK: Properties
    let navigationBarManager = NavigationManager()
    let authService = AuthService()
    
    var email: String = ""
    var agreeTerms: [UserTermDTO] = []

    // MARK: - Views
    private lazy var emailVerificationView = EmailVerificationView().then {
        // 버튼 액션 연결
        $0.emailField.actionButton.addTarget(self, action: #selector(didTapSendCode), for: .touchUpInside)
        $0.codeField.actionButton.addTarget(self, action: #selector(didTapVerifyCode), for: .touchUpInside)
        $0.nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        
        // 텍스트필드 이벤트 연결
        $0.emailField.innerTextField.addTarget(self, action: #selector(emailFieldDidChanged), for: .editingChanged)
        $0.codeField.innerTextField.addTarget(self, action: #selector(codeFieldDidChanged), for: .editingChanged)
    }
    
    //MARK: - init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(emailVerificationView)
        emailVerificationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setupNavigationBar()
    }
    
    // MARK: - NetWork
    func callPostSendCode(email: String) {
        self.email = email
        let request = AuthEmailSendReqeustDTO(email: email)
        
        authService.email(type: "SIGNUP", data: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.showToast()
                    self.emailVerificationView.codeField.setTextFieldInteraction(enabled: true)
                    
                case .failure(let error):
                    print("인증 메일 전송 실패: \(error)")
                    if case .serverError(let statusCode, _) = error,
                       statusCode == 409 {
                        self.emailVerificationView.emailField.setState(.error("이미 가입된 이메일입니다."))
                    }
                }
            }
        }
    }
    
    func callPostVerification(codeText: String) {
        let request = AuthEmailVerifyRequestDTO(email: email, authCode: codeText)
        
        authService.verification(data: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.handleVerificationSuccess()
                   
                case .failure(let error):
                    print("인증번호 확인 실패: \(error)")
                    self.emailVerificationView.codeField.setState(.error("인증번호가 올바르지 않습니다."))
                }
            }
        }
    }
    
    //MARK: - Functional
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func showToast() {
        ToastSecond.show(
            image: UIImage(named: "Style=Mail") ?? UIImage(),
            message: "인증번호를 발송했어요",
            font: .heading3SemiBold(),
            in: self.view
        )
    }
    
    private func handleVerificationSuccess() {
        // 코드 입력 필드 비활성화
        emailVerificationView.codeField.setTextFieldInteraction(enabled: false)
        emailVerificationView.codeField.setState(.none) // 그냥 비활성화만
        emailVerificationView.codeField.textColor = .gray300

        // 이메일 필드 Success 상태로 변경
        emailVerificationView.emailField.setTextFieldInteraction(enabled: false)
        emailVerificationView.emailField.setState(.success("이메일 인증이 완료되었습니다."))

        // 토스트 표시
        ToastSecond.show(
            image: UIImage(named: "Style=check") ?? UIImage(),
            message: "인증번호 인증을 완료했어요",
            font: .heading3SemiBold(),
            in: self.view
        )

        // 버튼 상태 업데이트
        emailVerificationView.emailField.setButtonState(isEnabled: false)
        emailVerificationView.codeField.setButtonState(isEnabled: false)
        emailVerificationView.nextButton.setButtonState(
            isEnabled: true,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
    }
    
    //MARK: Event
    @objc
    private func prevVC() {
        let emailErrorVC = EmailVerificationErrorViewController()
        let navController = UINavigationController(rootViewController: emailErrorVC)
        navController.modalPresentationStyle = .pageSheet
        presentSheet(navController, heightRatio: 314/932)
    }
    
    @objc
    private func didTapSendCode() {
        let emailField = emailVerificationView.emailField
        guard let emailText = emailField.text, !emailText.isEmpty else { return }
        callPostSendCode(email: emailText)
        emailField.setButtonState(isEnabled: false)
        view.endEditing(true)
    }
    
    @objc
    private func didTapVerifyCode() {
        guard let codeText = emailVerificationView.codeField.text, !codeText.isEmpty else { return }
        callPostVerification(codeText: codeText)
    }
    
    @objc
    private func didTapNextButton() {
        let userInfoVC = UserInfoInputViewController()
        
        // 약관 동의 데이터를 올바르게 전달
        userInfoVC.email = email
        userInfoVC.isVerified = true
        userInfoVC.agreeTerms = agreeTerms

        print("이메일 인증에서 전달된 약관 목록: \(agreeTerms)")

        self.navigationController?.pushViewController(userInfoVC, animated: true)
    }
    
    // 이메일 유효성 검사
    @objc
    private func emailFieldDidChanged() {
        let emailField = emailVerificationView.emailField
        
        guard let email = emailVerificationView.emailField.text else { return }
        let isEmailValid = isValidEmail(email)
        
        if email.isEmpty || isEmailValid {
            emailField.setState(.none)
        } else {
            emailField.setState(.error("올바르지 않은 이메일 형식입니다."))
        }
        
        emailField.setButtonState(isEnabled: isEmailValid)
    }
    
    // 코드 입력 유무
    @objc
    private func codeFieldDidChanged() {
        guard let code = emailVerificationView.codeField.text else { return }
        let codeField = emailVerificationView.codeField
        let isCodeValid = !code.isEmpty
        codeField.setButtonState(isEnabled: isCodeValid)
    }
    
   
    
    //MARK: - Setup UI
    private func setupNavigationBar() {
        navigationBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(prevVC),
            tintColor: .black
        )
        
        navigationBarManager.setTitle(
            to: navigationItem,
            title: "내 계정",
            textColor: .black
        )
        
        if let navBar = navigationController?.navigationBar {
            navigationBarManager.addBottomLine(to: navBar)
        }
    }
}
