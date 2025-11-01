//
//  UserInfoInputViewController.swift
//  GrowIT
//
//  Created by 강희정 on 1/25/25.
//

import UIKit
import SnapKit

class UserInfoInputViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    private let userInfoView = UserInfoInputView()
    private let navigationBarManager = NavigationManager()
    
    let authService = AuthService()
    
    // 이전 화면에서 전달받을 데이터
    var email: String = ""
    var isVerified: Bool = false
    var agreeTerms: [UserTermDTO] = [] // 약관 데이터 (termId 기반)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupActions()
        nextButtonState()
        setupKeyboardObservers()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        if agreeTerms.isEmpty {
            print("❌ 약관 데이터가 전달되지 않았습니다.")
        }
    }
    
    // MARK: - SetupView
    private func setupView() {
        self.view = userInfoView
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
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height
        userInfoView.scrollView.contentInset.bottom = keyboardHeight + 20
        
        userInfoView.scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight + 20
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        userInfoView.scrollView.contentInset.bottom = 0
        userInfoView.scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    
    
    // MARK: - Setup Actions
    private func setupActions() {
        userInfoView.passwordTextField.textField.isSecureTextEntry = true
        userInfoView.passwordCheckTextField.textField.isSecureTextEntry = true
        
        // delegate 설정
        [userInfoView.nameTextField,
         userInfoView.passwordTextField,
         userInfoView.passwordCheckTextField].forEach {
            $0.textField.delegate = self
        }
        
        // 리턴 키 타입
        userInfoView.nameTextField.textField.returnKeyType = .next
        userInfoView.passwordTextField.textField.returnKeyType = .next
        userInfoView.passwordCheckTextField.textField.returnKeyType = .done
        
        // 이름 이벤트 감지
        userInfoView.nameTextField.textField.addTarget(self, action: #selector(nameFieldDidChange), for: .editingChanged)
        
        // 비밀번호 이벤트 감지
        [userInfoView.passwordTextField.textField,
         userInfoView.passwordCheckTextField.textField].forEach {
            $0.addTarget(self, action: #selector(passwordFieldsDidChange), for: .editingChanged)
        }
        
        userInfoView.nextButton.addTarget(self, action: #selector(nextButtonTap), for: .touchUpInside)
    }
    
    // MARK: - Validation
    private func isValidPassword(_ password: String) -> Bool {
        // 영문, 숫자, 특수문자를 각각 하나 이상 포함, 8~30자
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*]).{8,30}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    private func isValidName(_ name: String) -> Bool {
        return name.count >= 1 && name.count <= 20
    }
    
    // MARK: - Update Button States
    private func nextButtonState() {
        guard let name = userInfoView.nameTextField.textField.text,
              let password = userInfoView.passwordTextField.textField.text,
              let confirmPassword = userInfoView.passwordCheckTextField.textField.text
        else { return }
        
        let isNameValid = isValidName(name)
        let isPasswordsMatch = isValidPassword(password) && password == confirmPassword
        let isFormValid = isNameValid && isPasswordsMatch
        
        userInfoView.nextButton.isEnabled = isFormValid
        userInfoView.nextButton.setButtonState(
            isEnabled: isFormValid,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
    }
    
    // MARK: - Actions
    @objc private func prevVC() {
        let emailErrorVC = EmailVerificationErrorViewController()
        let navController = UINavigationController(rootViewController: emailErrorVC)
        navController.modalPresentationStyle = .pageSheet
        presentSheet(navController, heightRatio: 314/932)
    }
    
    @objc private func nameFieldDidChange() {
        guard let name = userInfoView.nameTextField.textField.text else { return }
        
        if name.isEmpty {
            userInfoView.nameTextField.setState(.none)
        } else if !isValidName(name) {
            userInfoView.nameTextField.setState(.error("이름은 1~20자 이내로 입력해 주세요"))
        } else {
            userInfoView.nameTextField.setState(.none)
        }
        
        nextButtonState()
    }
    
    @objc private func passwordFieldsDidChange() {
        guard let password = userInfoView.passwordTextField.textField.text,
              let confirmPassword = userInfoView.passwordCheckTextField.textField.text
        else { return }
        
        // 비밀번호 유효성 검사
        if !password.isEmpty {
            if !isValidPassword(password) {
                userInfoView.passwordTextField.setState(.error("영문, 숫자, 특수문자를 포함한 8~30자로 입력해주세요"))
            } else {
                userInfoView.passwordTextField.setState(.none)
            }
        }
        
        // 두 필드 모두 비어있으면 초기화
        if password.isEmpty && confirmPassword.isEmpty {
            [userInfoView.passwordTextField, userInfoView.passwordCheckTextField].forEach {
                $0.setState(.none)
            }
            nextButtonState()
            return
        }
        
        // 비밀번호 확인 검사
        if !confirmPassword.isEmpty {
            if isValidPassword(password) && password == confirmPassword {
                userInfoView.passwordTextField.setState(.successNotLabel)
                userInfoView.passwordCheckTextField.setState(.success("비밀번호가 일치합니다"))
            } else if password != confirmPassword {
                userInfoView.passwordTextField.setState(.errorNotLabel)
                userInfoView.passwordCheckTextField.setState(.error("비밀번호가 일치하지 않습니다"))
            }
        }
        
        nextButtonState()
    }
    
    @objc private func nextButtonTap() {
        guard let name = userInfoView.nameTextField.textField.text,
              let password = userInfoView.passwordTextField.textField.text,
              !name.isEmpty, !password.isEmpty else {
            print("입력 값 누락: name이나 password가 비어있음")
            return
        }
        
        print("✅ 회원가입 시도")
        print("- 이름: \(name)")
        print("- 이메일: \(email)")
        print("- 비밀번호: \(password)")
        print("- 이메일 인증 여부: \(isVerified)")
        
        let mandatoryTermIds: Set<Int> = Set(agreeTerms.filter { $0.termId <= 10 && $0.termId >= 7 }.map { $0.termId })
        let agreedTermIds = Set(agreeTerms.filter { $0.agreed }.map { $0.termId })
        
        guard mandatoryTermIds.isSubset(of: agreedTermIds) else {
            print("❌ 필수 약관 (\(mandatoryTermIds))에 대한 동의가 필요합니다.")
            return
        }
        
        let request = AuthSignUpRequestDTO(
            isVerified: isVerified,
            email: email,
            name: name,
            password: password,
            userTerms: agreeTerms
        )
        
        authService.postAuthSignUp(type: "email", data: request) { result in
            switch result {
            case .success(let response):
                guard let tokenData = response.result else { return }
                self.handleSignUpSuccess(accessToken: tokenData.tokens.accessToken)
                UserDefaults.standard.set(tokenData.loginMethod, forKey: "loginMethod")
                
            case .failure(let error):
                print("❌ 회원가입 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleSignUpSuccess(accessToken: String) {
        print("회원가입 완료! 액세스 토큰: \(accessToken)")
        moveToSignUpCompleteScreen()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func moveToSignUpCompleteScreen() {
        let signUpCompleteVC = SignUpCompleteViewController()
        self.navigationController?.pushViewController(signUpCompleteVC, animated: true)
    }
    
    // UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userInfoView.nameTextField.textField {
            userInfoView.passwordTextField.textField.becomeFirstResponder()
        } else if textField == userInfoView.passwordTextField.textField {
            userInfoView.passwordCheckTextField.textField.becomeFirstResponder()
        } else if textField == userInfoView.passwordCheckTextField.textField {
            textField.resignFirstResponder()
        }
        return true
    }
}
