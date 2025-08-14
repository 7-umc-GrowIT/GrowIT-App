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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tapGesture)
        
        print("✅ 사용자 정보 입력 화면으로 전달된 이메일: \(email)")
        print("✅ 사용자 정보 입력 화면으로 전달된 인증 여부: \(isVerified)")
        print("✅ 사용자 정보 입력 화면으로 전달된 약관 목록: \(agreeTerms)") // 디버깅용 로그
        
        // 약관 데이터가 정상적으로 유지되었는지 확인
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
    
    // MARK: - Setup Actions
    private func setupActions() {
        userInfoView.passwordTextField.textField.isSecureTextEntry = true
        userInfoView.passwordCheckTextField.textField.isSecureTextEntry = true
        
        // delegate 설정 추가
        userInfoView.nameTextField.textField.delegate = self
        userInfoView.passwordTextField.textField.delegate = self
        userInfoView.passwordCheckTextField.textField.delegate = self
        
        // 리턴 키 타입 설정
        userInfoView.nameTextField.textField.returnKeyType = .next
        userInfoView.passwordTextField.textField.returnKeyType = .next
        userInfoView.passwordCheckTextField.textField.returnKeyType = .done
        
        // 두 필드 모두에 대해 변경 이벤트 감지
        userInfoView.passwordTextField.textField.addTarget(
            self, action: #selector(passwordFieldsDidChange), for: .editingChanged
        )
        userInfoView.passwordCheckTextField.textField.addTarget(
            self, action: #selector(passwordFieldsDidChange), for: .editingChanged
        )
        
        userInfoView.nextButton.addTarget(self, action: #selector(nextButtonTap), for: .touchUpInside)
    }
    
    // MARK: - Update Button States
    private func nextButtonState() {
        guard let password = userInfoView.passwordTextField.textField.text,
              let confirmPassword = userInfoView.passwordCheckTextField.textField.text
        else { return }
        
        // 비밀번호가 일치하고 둘 다 비어 있지 않을 경우 버튼 활성화
        let isPasswordsMatch = !password.isEmpty && password == confirmPassword
        
        // 버튼 상태 업데이트
        userInfoView.nextButton.setButtonState(
            isEnabled: isPasswordsMatch,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
    }
    
    // MARK: - Actions
    @objc private func prevVC() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func passwordFieldsDidChange() {
        guard let password = userInfoView.passwordTextField.textField.text,
              let confirmPassword = userInfoView.passwordCheckTextField.textField.text
        else { return }
        
        // 두 필드 모두 비어있으면 초기 상태로
        if password.isEmpty && confirmPassword.isEmpty {
            [userInfoView.passwordTextField, userInfoView.passwordCheckTextField].forEach {
                $0.clearError()
            }
            return
        }
        
        // 비밀번호 확인 필드가 비어있지 않을 때만 검증
        if !confirmPassword.isEmpty {
            if password == confirmPassword {
                [userInfoView.passwordTextField, userInfoView.passwordCheckTextField].forEach {
                    $0.setSuccess()
                    $0.titleLabel.textColor = .gray900
                    $0.textField.textColor = .positive400
                }
                userInfoView.passwordCheckTextField.errorLabel.text = "비밀번호가 일치합니다"
                userInfoView.passwordCheckTextField.errorLabel.textColor = .positive400
                userInfoView.passwordCheckTextField.errorLabel.isHidden = false
            } else {
                userInfoView.passwordCheckTextField.setError(message: "비밀번호가 일치하지 않습니다")
                userInfoView.passwordCheckTextField.titleLabel.textColor = .negative400
                userInfoView.passwordCheckTextField.textField.textColor = .negative400
            }
        }
        
        // 버튼 상태 업데이트
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

        // 필수 약관 ID를 TermsAgreeViewController에서 전달받은 값으로 설정
        let mandatoryTermIds: Set<Int> = Set(agreeTerms.filter { $0.termId <= 10 && $0.termId >= 7 }.map { $0.termId })

        // 사용자가 동의한 약관 ID 목록 (agreed == true)
        let agreedTermIds = Set(agreeTerms.filter { $0.agreed }.map { $0.termId })

        print("✅ 필수 약관 ID 목록: \(mandatoryTermIds)")
        print("✅ 사용자가 동의한 약관 ID 목록: \(agreedTermIds)")

        // 필수 약관이 모두 동의되었는지 확인
        guard mandatoryTermIds.isSubset(of: agreedTermIds) else {
            print("❌ 필수 약관 (\(mandatoryTermIds))에 대한 동의가 필요합니다.")
            return
        }
        
        let request = EmailSignUpRequest(
            isVerified: isVerified,
            email: email,
            name: name,
            password: password,
            userTerms: agreeTerms
        )
        
        print("✅ 서버로 전송되는 최종 요청 데이터:")
        print("- 이메일 인증 여부: \(request.isVerified)")
        print("- 이메일: \(request.email)")
        print("- 이름: \(request.name)")
        print("- 약관 동의 상태: \(request.userTerms)")
        
        authService.signUp(type: "email", data: request) { result in
            switch result {
            case .success(let response):
                print("✅ 회원가입 성공: \(response.message)")
                self.handleSignUpSuccess(accessToken: response.result.accessToken)

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
    
    // UITextFieldDelegate 메서드
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
