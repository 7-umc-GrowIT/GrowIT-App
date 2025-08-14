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
    let emailLoginView = EmailLoginView()
    let navigationBarManager = NavigationManager()
    
    let authService = AuthService()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupActions()
        loadCheckBoxState()
        updateLoginButtonState()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        emailLoginView.changePwdButton.addTarget(self, action: #selector(
            changePwdBtnTap), for: .touchUpInside)
        
        emailLoginView.singUpButton.addTarget(self, action: #selector(
            signUpBtnTap), for: .touchUpInside)
        
        emailLoginView.findEmailButton.addTarget(self, action: #selector(
            findEmailBtnTap), for: .touchUpInside
                                                 
        )
    }
    
    // MARK: - Setup View
    private func setupView() {
        self.view = emailLoginView
        self.navigationController?.isNavigationBarHidden = false
        
        // 네비게이션 타이틀 설정
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
    
    // MARK: - Setup Actions
    private func setupActions() {
        emailLoginView.emailSaveButton.addTarget(self, action: #selector(toggleCheckBox), for: .touchUpInside)
        
        emailLoginView.emailTextField.textField.addTarget(
            self, action: #selector(textFieldsDidChange), for: .editingChanged
        )
        
        emailLoginView.pwdTextField.textField.isSecureTextEntry = true
        emailLoginView.pwdTextField.textField.addTarget(
            self, action: #selector(textFieldsDidChange), for: .editingChanged
        )
        
        // 로그인 버튼
        emailLoginView.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }

    
    //MARK: - Text Fields Change Handler
   @objc private func textFieldsDidChange() {
       updateLoginButtonState()
   }
   
   private func updateLoginButtonState() {
       let isEmailValid = emailLoginView.emailTextField.validationRule?(emailLoginView.emailTextField.textField.text ?? "") ?? false
       let isPasswordValid = !(emailLoginView.pwdTextField.textField.text ?? "").isEmpty
       
       let isFormValid = isEmailValid && isPasswordValid
       
       emailLoginView.loginButton.setButtonState(
           isEnabled: isFormValid,
           enabledColor: .black, // 활성화 상태에서 검정색 배경
           disabledColor: .gray100, // 비활성화 상태의 배경색
           enabledTitleColor: .black,
           disabledTitleColor: .gray100
           
       )

       // 버튼 텍스트 색상 업데이트
       let textColor: UIColor = isFormValid ? .white : .gray400
       emailLoginView.loginButton.setTitleColor(textColor, for: .normal)
   }
    
    // MARK: - @objc methods
    
    @objc func prevVC() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func toggleCheckBox() {
        let isChecked = !emailLoginView.emailSaveButton.isSelected
        emailLoginView.emailSaveButton.isSelected = isChecked
        
        // 아이디 저장 상태를 UserDefaults에 저장
        UserDefaults.standard.set(isChecked, forKey: "isCheckBoxChecked")
    }
    
    @objc func loginButtonTapped() {
        guard let email = emailLoginView.emailTextField.textField.text, !email.isEmpty,
              let password = emailLoginView.pwdTextField.textField.text, !password.isEmpty else {
            print("이메일 또는 비밀번호가 비어 있습니다.")
            return
        }
        
        let loginRequest = EmailLoginRequest(email: email, password: password)
        
        authService.loginEmail(data: loginRequest) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.isSuccess {
                        // 옵셔널 해제 없이 바로 접근 가능
                        let tokenData = response.result

                        print("로그인 성공")

                        // 토큰 저장
                        UserDefaults.standard.set(tokenData.accessToken, forKey: "accessToken")
                        UserDefaults.standard.set(tokenData.refreshToken, forKey: "refreshToken")

                        print("AccessToken 저장됨")
                        print("RefreshToken 저장됨")

                        // 로그인 성공 후 다음 화면으로 이동
                        self.moveToNextScreen()
                    } else {
                        print("로그인 실패: \(response.message)")
                        self.emailLoginView.pwdTextField.setError(message: "비밀번호가 일치하지 않습니다.")
                    }

                case .failure(let error):
                    print("로그인 요청 실패: \(error.localizedDescription)")
                    self.emailLoginView.pwdTextField.setError(message: "비밀번호가 일치하지 않습니다.")
                }
            }
        }

    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    // 로그인 성공 후 다음 화면으로 이동
    private func moveToNextScreen() {
        let homeVC = CustomTabBarController(initialIndex: 1)
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    // 찾기, 변경, 회원가입 버튼 액션
    @objc func changePwdBtnTap() {
        let changePwdVC = ChangePasswordViewController()
        self.navigationController?.pushViewController(changePwdVC, animated: true)
    }
    
    @objc func signUpBtnTap() {
        let termsAgreeVC = TermsAgreeViewController()
        self.navigationController?.pushViewController(termsAgreeVC, animated: true)
    }
    
    @objc func findEmailBtnTap() {
        let findEmailVC = FindEmailViewController()
        self.navigationController?.pushViewController(findEmailVC, animated: true)
    }
    
    // MARK: - Load State
    private func loadCheckBoxState() {
        let isChecked = UserDefaults.standard.bool(forKey: "isCheckBoxChecked")
        emailLoginView.emailSaveButton.isSelected = isChecked
    }
}

