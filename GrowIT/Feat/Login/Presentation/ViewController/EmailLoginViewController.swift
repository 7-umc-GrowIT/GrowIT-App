//
//  EmailLoginViewController.swift
//  GrowIT
//
//  Created by 강희정 on 1/13/25.
//

import UIKit
import Foundation
import SnapKit

class EmailLoginViewController: UIViewController {
    
    //MARK: - Properties
    let navigationBarManager = NavigationManager()
    let authService = AuthService()
    
    //MARK: - View
    private lazy var emailLoginView = EmailLoginView().then {
        // Buttons
        $0.changePwdButton.addTarget(self, action: #selector(didTapChangePassword), for: .touchUpInside)
        $0.signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        $0.findEmailButton.addTarget(self, action: #selector(didTapFindEmail), for: .touchUpInside)
        $0.loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        $0.emailSaveButton.addTarget(self, action: #selector(didTapSaveEmail), for: .touchUpInside)
        
        // Textfields
        $0.emailTextField.textField.addTarget(self, action: #selector(emailFieldDidChange), for: .editingChanged)
        $0.pwdTextField.textField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
    }
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = emailLoginView
        
        setupNavigationBar()
        setupActions()
        loadCheckBoxState()
        updateLoginButtonState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - Setup UI
    private func setupNavigationBar() {
        navigationBarManager.setTitle(
            to: self.navigationItem,
            title: "이메일로 로그인",
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
    
    // MARK: - Validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    //MARK: - TextFields Handler
    @objc private func emailFieldDidChange() {
        guard let email = emailLoginView.emailTextField.textField.text else { return }
        let isEmailValid = isValidEmail(email)
        
        if email.isEmpty || isEmailValid {
            emailLoginView.emailTextField.setState(.none)
        } else {
            emailLoginView.emailTextField.setState(.error("올바르지 않은 이메일 형식입니다."))
        }
        updateLoginButtonState()
    }
    
    @objc private func textFieldsDidChange() {
        updateLoginButtonState()
    }
    
    private func updateLoginButtonState() {
        let email = emailLoginView.emailTextField.textField.text ?? ""
        let password = emailLoginView.pwdTextField.textField.text ?? ""
        
        let isEmailValid = isValidEmail(email)
        let isPasswordValid = !password.isEmpty
        
        let isFormValid = isEmailValid && isPasswordValid
        
        emailLoginView.loginButton.isEnabled = isFormValid
        emailLoginView.loginButton.setButtonState(
            isEnabled: isFormValid,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
    }
    
    // MARK: - Network
    private func callPostEmailLogin() {
        guard let email = emailLoginView.emailTextField.textField.text, !email.isEmpty,
              let password = emailLoginView.pwdTextField.textField.text, !password.isEmpty else {
            print("이메일 또는 비밀번호가 비어 있습니다.")
            return
        }
        
        let loginRequest = AuthLoginRequestDTO(email: email, password: password)
        
        authService.loginEmail(data: loginRequest) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.isSuccess {
                        guard let tokenData = response.result else { return }
                        let accessToken = tokenData.tokens.accessToken
                        let refreshToken = tokenData.tokens.refreshToken
                        TokenManager.shared.saveTokens(
                            accessToken: accessToken,
                            refreshToken: refreshToken
                        )
                        
                        UserDefaults.standard.set(tokenData.loginMethod, forKey: "loginMethod")
                        
                        if self.emailLoginView.emailSaveButton.isSelected {
                            UserDefaults.standard.set(email, forKey: "savedEmail")
                        } else {
                            UserDefaults.standard.removeObject(forKey: "savedEmail")
                        }
                        
                        self.navigateToMainScreen()
                    } else {
                        switch response.message {
                        case "이메일 또는 비밀번호가 일치하지 않습니다.":
                            self.emailLoginView.emailTextField.setState(.errorNotLabel)
                            self.emailLoginView.pwdTextField.setState(.error("입력한 이메일 또는 비밀번호가 일치하지 않습니다"))
                        case "사용자를 찾을 수 없습니다.":
                            self.emailLoginView.emailTextField.setState(.error("가입되지 않은 이메일입니다"))
                        default:
                            break
                        }
                    }
                    
                case .failure(let error):
                    print("로그인 요청 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Functional
    private func navigateToMainScreen() {
        let homeVC = CustomTabBarController(initialIndex: 1)
        let nav = UINavigationController(rootViewController: homeVC)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }
    
    //MARK: Event
    @objc private func prevVC() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapLoginButton() {
        callPostEmailLogin()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // 찾기, 변경, 회원가입 버튼 액션
    @objc func didTapChangePassword() {
        let changePwdVC = ChangePasswordViewController(isMypage: false)
        self.navigationController?.pushViewController(changePwdVC, animated: true)
    }
    
    @objc func didTapSignUp() {
        let termsAgreeVC = TermsAgreeViewController()
        self.navigationController?.pushViewController(termsAgreeVC, animated: true)
    }
    
    @objc func didTapFindEmail() {
        let accountInquiryVC = AccountInquiryViewController()
        presentSheet(accountInquiryVC, heightRatio: 314/932, fixedHeight: 314)
    }
    
    // 이메일 저장
    @objc private func didTapSaveEmail() {
        let isChecked = !emailLoginView.emailSaveButton.isSelected
        emailLoginView.emailSaveButton.isSelected = isChecked
        UserDefaults.standard.set(isChecked, forKey: "isCheckBoxChecked")
    }
    
    private func loadCheckBoxState() {
        let isChecked = UserDefaults.standard.bool(forKey: "isCheckBoxChecked")
        emailLoginView.emailSaveButton.isSelected = isChecked
        
        if isChecked {
            let savedEmail = UserDefaults.standard.string(forKey: "savedEmail") ?? ""
            emailLoginView.emailTextField.textField.text = savedEmail
        }
    }
}
