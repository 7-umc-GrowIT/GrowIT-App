//
//  EmailVerificationViewController.swift
//  GrowIT
//
//  Created by 강희정 on 1/25/25.
//

import UIKit
import Foundation

class EmailVerificationViewController: UIViewController {
    
    // MARK: - Properties
    private let emailVerificationView = EmailVerificationView()
    private let navigationBarManager = NavigationManager()
    private var isEmailFieldDisabled = false
    private var isCodeFieldDisabled = false
    
    let authService = AuthService()
    private var email: String = ""
    
    var agreeTerms: [UserTermDTO] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupActions()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup View
    private func setupView() {
        self.view = emailVerificationView
        self.navigationController?.isNavigationBarHidden = false
        
        navigationBarManager.setTitle(
            to: self.navigationItem,
            title: "회원가입",
            textColor: .gray900,
            font: .heading1Bold()
        )
        
        navigationBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(prevVC)
        )
        
        emailVerificationView.nextButton.addTarget(self, action: #selector(
            nextButtonTap), for: .touchUpInside)
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
        // TextField 이벤트 설정
        emailVerificationView.emailTextField.textField.addTarget(
            self, action: #selector(textFieldsDidChange), for: .editingChanged
        )
        emailVerificationView.codeTextField.textField.addTarget(
            self, action: #selector(textFieldsDidChange), for: .editingChanged
        )
        
        // 버튼 이벤트 설정
        emailVerificationView.sendCodeButton.addTarget(
            self, action: #selector(sendCodeButtonTapped), for: .touchUpInside
        )
        emailVerificationView.certificationButton.addTarget(
            self, action: #selector(certificationButtonTapped), for: .touchUpInside
        )
    }
    
    // MARK: - TextField Change Handler
    @objc private func textFieldsDidChange() {
        updateSendCodeButtonState()
        updateCertificationButtonState()
    }
    
    // MARK: - Update Button States
    private func updateSendCodeButtonState() {
        guard let emailText = emailVerificationView.emailTextField.textField.text else { return }
        
        // 이메일 필드와 인증번호 필드 모두 활성화 상태 유지
        emailVerificationView.emailTextField.setTextFieldInteraction(enabled: true)
        emailVerificationView.codeTextField.setTextFieldInteraction(enabled: true)
        
        
        if emailText.isEmpty {
            emailVerificationView.emailTextField.clearError()
        } else if isValidEmail(emailText) {
            emailVerificationView.emailTextField.clearError()
        } else {
            emailVerificationView.emailTextField.setError(message: "올바르지 않은 이메일 형식입니다.")
        }
        
        let isEmailValid = isValidEmail(emailText)
        emailVerificationView.sendCodeButton.setButtonState(
            isEnabled: isEmailValid,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
    }
    
    
    private func updateCertificationButtonState() {
        guard let codeText = emailVerificationView.codeTextField.textField.text else { return }
        
        if isCodeFieldDisabled {
            setCodeFieldDisabledUI()
            return
        }
        
        if codeText.isEmpty {
            emailVerificationView.codeTextField.clearError()
        } else {
            emailVerificationView.codeTextField.clearError()
        }
        
        
        let isCodeValid = !codeText.isEmpty
        emailVerificationView.certificationButton.setButtonState(
            isEnabled: isCodeValid,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
    }
    
    // MARK: - Helper
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func setCodeFieldDisabledUI() {
        emailVerificationView.codeTextField.setTextFieldInteraction(enabled: false)
        emailVerificationView.codeTextField.titleLabel.textColor = .gray300
        emailVerificationView.codeTextField.textField.textColor = .gray300
        emailVerificationView.codeTextField.textField.backgroundColor = .gray100
        
    }
    
    // MARK: - Actions
    @objc private func prevVC() {
        let emailErrorVC = EmailVerificationErrorViewController()
        let navController = UINavigationController(rootViewController: emailErrorVC)
        navController.modalPresentationStyle = .pageSheet
        presentPageSheet(viewController: navController, detentFraction: 0.37)
    }
    
    @objc private func sendCodeButtonTapped() {
        guard let emailText = emailVerificationView.emailTextField.textField.text, !emailText.isEmpty else {
            print("이메일 입력 필요")
            return
        }
        
        self.view.endEditing(true)
        
        email = emailText
        
        let request = SendEmailVerifyRequest(email: emailText)
        
        authService.email(type: "SIGNUP", data: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("인증 메일 전송 성공 이메일: \(response.email)")
                    print("응답 메시지: \(response.message)")

                    self.isEmailFieldDisabled = true
                    self.emailVerificationView.emailTextField.setTextFieldInteraction(enabled: false)
                    
                    // 인증번호 보내기 버튼 비활성화
                    self.emailVerificationView.sendCodeButton.setButtonState(
                        isEnabled: false,
                        enabledColor: .black,
                        disabledColor: .gray100,
                        enabledTitleColor: .white,
                        disabledTitleColor: .gray400
                    )
                    
                    // 토스트 메시지 표시
                    let toastImage = UIImage(named: "Style=Mail") ?? UIImage()
                    CustomToast(containerWidth: 225).show(
                        image: toastImage,
                        message: "인증번호를 발송했어요",
                        font: UIFont.heading3SemiBold()
                    )
                    
                case .failure(let error):
                    print("인증 메일 전송 실패: \(error)")
                }
            }
        }
        
    }
    
    @objc private func certificationButtonTapped() {
        guard let codeText = emailVerificationView.codeTextField.textField.text, !codeText.isEmpty else {
            print("인증번호 입력하세요")
            return
        }
        
        let request = EmailVerifyRequest(email: email, authCode: codeText)
        
        authService.verification(data: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("인증번호 확인 성공 메시지: \(response.message)")
                    
                    // 인증 성공 UI 업데이트
                    self.handleVerificationSuccess()
                    
                
                case .failure(let error):
                    print("인증번호 확인 실패: \(error)")
                    
                    
                    // 서버 응답에서 인증 실패 메시지를 확인하고 필드 업데이트
                    self.emailVerificationView.codeTextField.setError(message: "인증번호가 올바르지 않습니다.")
                }
            }
        }
    }
    
    private func handleVerificationSuccess() {
        // 인증번호 필드 비활성화
        self.isCodeFieldDisabled = true
        self.setCodeFieldDisabledUI()
        
        // 이메일 필드 Success 상태로 변경
        self.emailVerificationView.emailTextField.setTextFieldInteraction(enabled: false)
        self.emailVerificationView.emailTextField.setSuccess()
        
        // 성공 메시지 표시
        self.emailVerificationView.emailTextField.errorLabel.text = "이메일 인증이 완료되었습니다."
        self.emailVerificationView.emailTextField.errorLabel.textColor = UIColor.positive400
        self.emailVerificationView.emailTextField.errorLabel.isHidden = false
        self.emailVerificationView.emailTextField.errorLabelTopConstraint?.update(offset: 4)
        
        // 인증하기 버튼 비활성화
        self.emailVerificationView.certificationButton.setButtonState(
            isEnabled: false,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
        
        self.emailVerificationView.sendCodeButton.setButtonState(
            isEnabled: false,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
        
        // 토스트 메시지 표시
        let toastImage = UIImage(named: "Style=check") ?? UIImage()
        CustomToast(containerWidth: 258).show(
            image: toastImage,
            message: "인증번호 인증을 완료했어요",
            font: UIFont.heading3SemiBold()
        )
        
        // 버튼 상태 업데이트
        self.emailVerificationView.nextButton.setButtonState(
            isEnabled: true,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
    }

    
    @objc func nextButtonTap() {
        let userInfoVC = UserInfoInputViewController()
        
        // 약관 동의 데이터를 올바르게 전달
        userInfoVC.email = email
        userInfoVC.isVerified = true
        userInfoVC.agreeTerms = agreeTerms

        print("이메일 인증에서 전달된 약관 목록: \(agreeTerms)")

        self.navigationController?.pushViewController(userInfoVC, animated: true)
    }
    
    @objc private func dismissKeyboard() {
            view.endEditing(true)
    }
    
}
