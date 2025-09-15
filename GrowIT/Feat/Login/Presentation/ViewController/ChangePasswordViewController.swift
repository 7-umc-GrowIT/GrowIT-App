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
    private let navigationBarManager = NavigationManager()
    var shouldShowExitModal: Bool = true
    
    let userService = UserService()
    let authService = AuthService()
    
    private var email: String = ""
    private var isMypage: Bool = false
    private var meEmail: String = ""

    // MARK: - View
    private lazy var changePasswordView = ChangePasswordView().then {
        // 버튼 액션
        $0.emailField.actionButton.addTarget(self, action: #selector(sendCodeButtonTapped), for: .touchUpInside)
        $0.codeField.actionButton.addTarget(self, action: #selector(certificationButtonTapped), for: .touchUpInside)
        $0.changePwdButton.addTarget(self, action: #selector(changePwdButtonTapped), for: .touchUpInside)
        
        // 텍스트필드 이벤트
        $0.emailField.innerTextField.addTarget(self, action: #selector(emailTextFieldsDidChange), for: .editingChanged)
        $0.codeField.innerTextField.addTarget(self, action: #selector(codeTextFieldsDidChange), for: .editingChanged)
        $0.newPwdTextField.textField.isSecureTextEntry = true
        $0.newPwdTextField.textField.addTarget(self, action: #selector(changePasswordTextFieldsDidChange), for: .editingChanged)
        $0.pwdCheckTextField.textField.isSecureTextEntry = true
        $0.pwdCheckTextField.textField.addTarget(self, action: #selector(changePasswordTextFieldsDidChange), for: .editingChanged)
    }
    
    // MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = changePasswordView

        setupNavigationBar()
        setupActions()
        setMypageUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        emailTextFieldsDidChange()
        codeTextFieldsDidChange()
    }
    
    init(isMypage: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.isMypage = isMypage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup NavigationBar
    private func setupNavigationBar() {
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
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - NetWork
    private func callPatchUserPassword(_ email: String,
                                       _ newPassword: String,
                                       _ passwordCheck: String) {
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
                    
                    CustomToast(containerWidth: 225).show(
                        image: UIImage(named: "Style=check") ?? UIImage(),
                        message: "비밀번호를 변경했어요",
                        font: UIFont.heading3SemiBold()
                    )
                    
                    self?.navigationController?.popViewController(animated: true)

                case .failure(let error):
                    print("비밀번호 변경 실패: \(error)")
                    self?.changePasswordView.pwdCheckTextField.setState(.error("비밀번호 변경에 실패했습니다."))
                }
            }
        }
    }
    
    private func callPostSendCode(email: String) {
        let request = AuthEmailSendReqeustDTO(email: email)
        
        authService.email(type: "PASSWORD_RESET", data: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.changePasswordView.emailField.setTextFieldInteraction(enabled: false)
                    self.changePasswordView.codeField.setTextFieldInteraction(enabled: true)
                    
                    CustomToast(containerWidth: 225).show(
                        image: UIImage(named: "Style=Mail") ?? UIImage(),
                        message: "인증번호를 발송했어요",
                        font: UIFont.heading3SemiBold()
                    )
                    
                    self.changePasswordView.emailField.setButtonState(isEnabled: false)
                    
                case .failure(let error):
                    print("인증 메일 전송 실패: \(error)")
                    if case .serverError(let statusCode, let message) = error {
                        if statusCode == 400 {
                            self.changePasswordView.emailField.setState(.error("소셜 로그인은 비밀번호 재설정이 불가능합니다"))
                        } else if statusCode == 404 {
                            self.changePasswordView.emailField.setState(.error("가입되지 않은 이메일입니다"))
                        } else {
                            self.changePasswordView.emailField.setState(.error(message))
                        }
                    }
                }
            }
        }
    }
    
    private func callPostVerification(email: String, codeText: String) {
        let request = AuthEmailVerifyRequestDTO(email: email, authCode: codeText)

        authService.verification(data: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.handleVerificationSuccess()

                case .failure(let error):
                    print("인증번호 확인 실패: \(error)")
                    self?.changePasswordView.codeField.setState(.error("인증번호가 올바르지 않습니다."))
                }
            }
        }
    }
    
    private func callGetMeEmail() {
        userService.getMeEmail(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.changePasswordView.emailField.innerTextField.text = data.email
                self.emailTextFieldsDidChange()
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    // MARK: - Validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*]).{8,30}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    private func setMypageUI() {
        if isMypage {
            callGetMeEmail()
            changePasswordView.codeField.setTextFieldInteraction(enabled: true)
            changePasswordView.emailField.setTextFieldInteraction(enabled: false)
            changePasswordView.emailField.setState(.hint("가입 시 사용했던 이메일입니다"))
        }
    }
    
    private func handlePasswordChange() {
        guard let email = changePasswordView.emailField.text,
              let newPassword = changePasswordView.newPwdTextField.textField.text,
              let passwordCheck = changePasswordView.pwdCheckTextField.textField.text else { return }
        
        callPatchUserPassword(email, newPassword, passwordCheck)
    }

    // MARK: - TextField Event
    @objc private func emailTextFieldsDidChange() {
        guard let emailText = changePasswordView.emailField.text else { return }
        
        let isEmailValid = isValidEmail(emailText)
        
        if emailText.isEmpty || isEmailValid {
            changePasswordView.emailField.setState(.none)
        } else {
            changePasswordView.emailField.setState(.error("올바르지 않은 이메일 형식입니다."))
        }
        
        changePasswordView.emailField.setButtonState(isEnabled: isEmailValid)
    }
    
    @objc private func codeTextFieldsDidChange() {
        guard let codeText = changePasswordView.codeField.text else { return }
        let isCodeValid = !codeText.isEmpty
        changePasswordView.codeField.setButtonState(isEnabled: isCodeValid)
    }
    
    @objc private func changePasswordTextFieldsDidChange() {
        guard let newPassword = changePasswordView.newPwdTextField.textField.text,
              let confirmPassword = changePasswordView.pwdCheckTextField.textField.text else { return }
        
        // 둘 다 비어있는 경우
        if newPassword.isEmpty || confirmPassword.isEmpty {
            changePasswordView.newPwdTextField.setState(.none)
            changePasswordView.pwdCheckTextField.setState(.none)
            return
        }
        
        // 새로운 비밀번호가 유효성에 맞지 않는 경우
        isValidPassword(newPassword) ? changePasswordView.newPwdTextField.setState(.none) : changePasswordView.newPwdTextField.setState(.error("영문, 숫자, 특수문자를 포함한 8~30자로 입력해주세요"))
        
        // 비밀번호 확인
        if !confirmPassword.isEmpty {
            if newPassword == confirmPassword {
                changePasswordView.newPwdTextField.setState(.successNotLabel)
                changePasswordView.pwdCheckTextField.setState(.success("비밀번호가 일치합니다"))
            } else {
                changePasswordView.pwdCheckTextField.setState(.errorNotLabel)
                changePasswordView.pwdCheckTextField.setState(.error("비밀번호가 일치하지 않습니다"))
            }
        }
        
        // 두 비밀번호가 맞고 새로운 비밀번호가 유효성에 맞는 경우
        let isPasswordsMatch = isValidPassword(newPassword) && newPassword == confirmPassword
        changePasswordView.changePwdButton.setButtonState(
            isEnabled: isPasswordsMatch,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
    }
    
    // MARK: - Events
    @objc private func prevVC() {
        if shouldShowExitModal {
            let changePwdErrorVC = ChangePasswordErrorViewController()
            let navController = UINavigationController(rootViewController: changePwdErrorVC)
            navController.modalPresentationStyle = .pageSheet
            presentSheet(navController, heightRatio: 0.37)
        } else {
            if let nav = navigationController {
                nav.popViewController(animated: true)
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc private func sendCodeButtonTapped() {
        guard let emailText = changePasswordView.emailField.text,
              !emailText.isEmpty else { return }
        callPostSendCode(email: emailText)
    }
    
    @objc private func certificationButtonTapped() {
        guard let emailText = changePasswordView.emailField.text,
              let codeText = changePasswordView.codeField.text,
              !codeText.isEmpty else { return }
        callPostVerification(email: emailText, codeText: codeText)
    }
    
    private func handleVerificationSuccess() {
        changePasswordView.codeField.setTextFieldInteraction(enabled: false)
        changePasswordView.emailField.setTextFieldInteraction(enabled: false)
        changePasswordView.newPwdTextField.setTextFieldInteraction(enabled: true)
        changePasswordView.pwdCheckTextField.setTextFieldInteraction(enabled: true)
        
        changePasswordView.codeField.setButtonState(isEnabled: false)
        changePasswordView.emailField.setButtonState(isEnabled: false)
        
        CustomToast(containerWidth: 258).show(
            image: UIImage(named: "Style=check") ?? UIImage(),
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
