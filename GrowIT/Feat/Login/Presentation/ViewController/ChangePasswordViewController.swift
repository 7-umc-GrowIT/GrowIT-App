//
//  ChangePasswordViewController.swift
//  GrowIT
//
//  Created by 강희정 on 1/17/25.
//

import UIKit
import Foundation
import SnapKit

class ChangePasswordViewController: UIViewController {
    
    // MARK: - Properties
    private let changePasswordView = ChangePasswordView()
    private let navigationBarManager = NavigationManager()
    private var isEmailFieldDisabled = false
    private var isCodeFieldDisabled = false
    
    private var userService: UserService {
        return UserService()
    }
    
    private var authService: AuthService {
        return AuthService()
    }
    
    private var email: String = ""
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupActions()
        updateSendCodeButtonState()
        updateCertificationButtonState()
        updatePasswordMatchState()
        updatePwdChangeBtnState()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup View
    private func setupView() {
        self.view = changePasswordView
        self.navigationController?.isNavigationBarHidden = false
        
        navigationBarManager.setTitle(
            to: self.navigationItem,
            title: "비밀번호 변경",
            textColor: .gray900,
            font: .heading1Bold()
        )
        
        navigationBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(prevVC)
        )
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
        // TextField 이벤트 설정
        changePasswordView.emailTextField.textField.addTarget(
            self, action: #selector(textFieldsDidChange), for: .editingChanged
        )
        changePasswordView.codeTextField.textField.addTarget(
            self, action: #selector(textFieldsDidChange), for: .editingChanged
        )
        changePasswordView.newPwdTextField.textField.isSecureTextEntry = true
        changePasswordView.newPwdTextField.textField.addTarget(
            self, action: #selector(textFieldsDidChange), for: .editingChanged
        )
        changePasswordView.pwdCheckTextField.textField.isSecureTextEntry = true
        changePasswordView.pwdCheckTextField.textField.addTarget(
            self, action: #selector(textFieldsDidChange), for: .editingChanged
        )
        
        // 버튼 이벤트 설정
        changePasswordView.sendCodeButton.addTarget(
            self, action: #selector(sendCodeButtonTapped), for: .touchUpInside
        )
        changePasswordView.certificationButton.addTarget(
            self, action: #selector(certificationButtonTapped), for: .touchUpInside
        )
        changePasswordView.changePwdButton.addTarget(
            self, action: #selector(changePwdButtonTapped), for: .touchUpInside
        )
    }
    
    // MARK: - TextField Change Handler
    @objc private func textFieldsDidChange() {
        updateSendCodeButtonState()
        updateCertificationButtonState()
        updatePasswordMatchState()
        updatePwdChangeBtnState()
    }
    
    // MARK: - Update Button States
    private func updateSendCodeButtonState() {
        guard let emailText = changePasswordView.emailTextField.textField.text else { return }
        
        if isEmailFieldDisabled {
            setEmailFieldDisabledUI()
            return
        }
        
        if emailText.isEmpty {
            changePasswordView.emailTextField.clearError()
            changePasswordView.emailLabel.isHidden = false  // 기본 라벨 표시
        } else if isValidEmail(emailText) {
            changePasswordView.emailTextField.clearError()
            changePasswordView.emailLabel.isHidden = false  // 기본 라벨 표시
        } else {
            changePasswordView.emailTextField.setError(message: "올바르지 않은 이메일 형식입니다.")
            changePasswordView.emailLabel.isHidden = true   // 오류 메시지가 표시될 때는 기본 라벨 숨김
        }
        
        let isEmailValid = isValidEmail(emailText)
        changePasswordView.sendCodeButton.setButtonState(
            isEnabled: isEmailValid,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
    }
    
    private func updateCertificationButtonState() {
        guard let codeText = changePasswordView.codeTextField.textField.text else { return }

        if isCodeFieldDisabled {
            setCodeFieldDisabledUI()
            return
        }

        // 인증번호 유효성 검사: 8자리 (영문 + 숫자)
        let isValidCode = isValidVerificationCode(codeText)

        if codeText.isEmpty {
            changePasswordView.codeTextField.clearError()
        } else if !isValidCode {
            changePasswordView.codeTextField.setError(message: "올바른 인증번호를 입력하세요.")
        } else {
            changePasswordView.codeTextField.clearError()
        }

        // 인증번호가 8자리일 때 버튼 활성화
        changePasswordView.certificationButton.setButtonState(
            isEnabled: isValidCode,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
    }

    // 인증번호 형식 검증 함수 추가
    private func isValidVerificationCode(_ code: String) -> Bool {
        let codeRegex = "^[A-Za-z0-9]{8}$" // 영문+숫자로 8자리
        return NSPredicate(format: "SELF MATCHES %@", codeRegex).evaluate(with: code)
    }

    
    private func updatePwdChangeBtnState() {
        guard let newPassword = changePasswordView.newPwdTextField.textField.text,
              let confirmPassword = changePasswordView.pwdCheckTextField.textField.text else { return }
        
        let isPasswordsMatch = !newPassword.isEmpty && newPassword == confirmPassword
        
        changePasswordView.changePwdButton.setButtonState(
            isEnabled: isPasswordsMatch,
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
    
    private func setEmailFieldDisabledUI() {
        changePasswordView.emailTextField.setTextFieldInteraction(enabled: false)
        changePasswordView.emailTextField.textField.isUserInteractionEnabled = false
        changePasswordView.emailTextField.titleLabel.textColor = .gray300
        changePasswordView.emailTextField.textField.textColor = .gray300
        changePasswordView.emailTextField.textField.backgroundColor = .gray100
    }
    
    private func setCodeFieldDisabledUI() {
        changePasswordView.codeTextField.setTextFieldInteraction(enabled: false)
        changePasswordView.codeTextField.titleLabel.textColor = .gray300
        changePasswordView.codeTextField.textField.textColor = .gray300
        changePasswordView.codeTextField.textField.backgroundColor = .gray100
    }
    
    // MARK: - API
    private func handlePasswordChange() {
        guard let email = changePasswordView.emailTextField.textField.text,
              let newPassword = changePasswordView.newPwdTextField.textField.text,
              let passwordCheck = changePasswordView.pwdCheckTextField.textField.text else {
            return
        }
        
        let request = UserPatchRequestDTO(
            isVerified: true,
            email: email,
            password: newPassword,
            passwordCheck: passwordCheck
        )

        userService.patchUserPassword(data: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("비밀번호 변경 성공: \(response.message)")
                    
                    // 성공 메시지 표시
                    let toastImage = UIImage(named: "Style=check") ?? UIImage()
                    CustomToast(containerWidth: 225).show(
                        image: toastImage,
                        message: "비밀번호를 변경했어요",
                        font: UIFont.heading3SemiBold()
                    )
                    
                    // 이전 화면으로 이동
                    self?.navigationController?.popViewController(animated: true)

                case .failure(let error):
                    print("비밀번호 변경 실패: \(error)")
                    self?.changePasswordView.pwdCheckTextField.setError(message: "비밀번호 변경에 실패했습니다.")
                }
            }
        }
    }

    
    // MARK: - Actions
    @objc private func prevVC() {
        let changePwdErrorVC = ChangePasswordErrorViewController()
        let navController = UINavigationController(rootViewController: changePwdErrorVC)
        navController.modalPresentationStyle = .pageSheet
        presentPageSheet(viewController: navController, detentFraction: 0.37)
    }
    
    private func updatePasswordMatchState() {
        guard let newPassword = changePasswordView.newPwdTextField.textField.text,
              let confirmPassword = changePasswordView.pwdCheckTextField.textField.text else { return }
        
        if confirmPassword.isEmpty {
            changePasswordView.pwdCheckTextField.clearError()
            return
        }
        
        if newPassword == confirmPassword {
            changePasswordView.newPwdTextField.setSuccess()
            changePasswordView.pwdCheckTextField.setSuccess()
            
            changePasswordView.newPwdTextField.titleLabel.textColor = .gray900
            changePasswordView.pwdCheckTextField.titleLabel.textColor = .gray900
            changePasswordView.newPwdTextField.textField.textColor = .positive400
            changePasswordView.pwdCheckTextField.textField.textColor = .positive400
            
            // 성공 메시지 표시 부분 수정
            changePasswordView.pwdCheckTextField.errorLabel.text = "비밀번호가 일치합니다"
            changePasswordView.pwdCheckTextField.errorLabel.textColor = .positive400
            changePasswordView.pwdCheckTextField.errorLabel.isHidden = false
            changePasswordView.pwdCheckTextField.errorLabelTopConstraint?.update(offset: 4) // 간격 조정
        } else {
            changePasswordView.newPwdTextField.setError(message: "")
            changePasswordView.pwdCheckTextField.setError(message: "비밀번호가 일치하지 않습니다")
            
            changePasswordView.newPwdTextField.titleLabel.textColor = .negative400
            changePasswordView.pwdCheckTextField.titleLabel.textColor = .negative400
            changePasswordView.newPwdTextField.textField.textColor = .negative400
            changePasswordView.pwdCheckTextField.textField.textColor = .negative400
            
            changePasswordView.pwdCheckTextField.errorLabel.isHidden = false
            changePasswordView.pwdCheckTextField.errorLabelTopConstraint?.update(offset: 4) // 에러 메시지도 동일한 간격 적용
        }
    }
    
    @objc private func sendCodeButtonTapped() {
        guard let emailText = changePasswordView.emailTextField.textField.text,
              !emailText.isEmpty else {
            return
        }
        
        email = emailText
        let request = SendEmailVerifyRequest(email: emailText)
        
        authService.email(type: "PASSWORD_RESET", data: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("인증 메일 전송 성공 이메일: \(response.email)")
                    print("응답 메시지: \(response.message)")

                    self.isEmailFieldDisabled = true
                    self.changePasswordView.emailTextField.setTextFieldInteraction(enabled: false)
                    
                    let toastImage = UIImage(named: "Style=Mail") ?? UIImage()
                    CustomToast(containerWidth: 225).show(
                        image: toastImage,
                        message: "인증번호를 발송했어요",
                        font: UIFont.heading3SemiBold()
                    )
                    
                    self.changePasswordView.sendCodeButton.setButtonState(
                        isEnabled: false,
                        enabledColor: .black,
                        disabledColor: .gray100,
                        enabledTitleColor: .white,
                        disabledTitleColor: .gray400
                    )

                case .failure(let error):
                    print("인증 메일 전송 실패: \(error)")
                    self.changePasswordView.emailLabel.isHidden = true  // 기본 라벨 숨기기
                    self.changePasswordView.emailTextField.setError(message: "이메일 전송에 실패했습니다.")
                }
            }
        }
    }
    
    @objc private func certificationButtonTapped() {
        guard let emailText = changePasswordView.emailTextField.textField.text,
              let codeText = changePasswordView.codeTextField.textField.text,
              !codeText.isEmpty else {
            print("인증번호 입력하세요")
            return
        }

        let request = EmailVerifyRequest(email: emailText, authCode: codeText)

        authService.verification(data: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("인증번호 확인 성공 메시지: \(response.message)")

                    // 인증 성공 시 UI 업데이트 로직 추가
                    self?.handleVerificationSuccess()

                case .failure(let error):
                    print("인증번호 확인 실패: \(error)")
                    self?.changePasswordView.codeTextField.setError(message: "인증번호가 올바르지 않습니다.")
                }
            }
        }
    }
    
    private func handleVerificationSuccess() {
        // 인증 성공 시, 인증번호 입력 필드를 비활성화
        self.isCodeFieldDisabled = true
        self.setCodeFieldDisabledUI()

        // 이메일 입력 필드 비활성화
        self.changePasswordView.emailTextField.setTextFieldInteraction(enabled: false)
        
        // 기본 UI 설정
        self.changePasswordView.emailTextField.textField.layer.borderColor = UIColor.gray100.cgColor
        self.changePasswordView.emailTextField.textField.backgroundColor = .gray100
        self.changePasswordView.emailTextField.textField.textColor = .gray300
        self.changePasswordView.emailTextField.titleLabel.textColor = .gray300

        // 인증 완료 후 버튼 비활성화
        self.changePasswordView.certificationButton.setButtonState(
            isEnabled: false,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray300
        )

        self.changePasswordView.sendCodeButton.setButtonState(
            isEnabled: false,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray300
        )

        // 인증 성공 시 토스트 메시지 표시
        let toastImage = UIImage(named: "Style=check") ?? UIImage()
        CustomToast(containerWidth: 258).show(
            image: toastImage,
            message: "인증번호 인증을 완료했어요",
            font: UIFont.heading3SemiBold()
        )
    }
    
    @objc private func changePwdButtonTapped() {
        handlePasswordChange()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
