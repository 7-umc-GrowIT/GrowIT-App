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
    var shouldShowExitModal: Bool = true /// 뒤로가기 시 에러 모달을 띄울지 여부
    
    let userService = UserService()
    let authService = AuthService()
    
    private var email: String = ""
    private var isMypage: Bool = false
    private var meEmail: String = ""

    // MARK: - view
    private lazy var changePasswordView = ChangePasswordView().then {
        // Buttons
        $0.sendCodeButton.addTarget(self, action: #selector(sendCodeButtonTapped), for: .touchUpInside)
        $0.certificationButton.addTarget(self, action: #selector(certificationButtonTapped), for: .touchUpInside)
        $0.changePwdButton.addTarget(self, action: #selector(changePwdButtonTapped), for: .touchUpInside)
        
        //  Textfields
        $0.emailTextField.textField.addTarget(self, action: #selector(emailTextFieldsDidChange), for: .editingChanged)
        $0.codeTextField.textField.addTarget(self, action: #selector(codeTextFieldsDidChange), for: .editingChanged)
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
    
    // MARK: - Setup Actions
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - NetWork
    // 비밀번호 변경 API
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
    
    // 인증번호 발송 API
    private func callPostSendCode(email: String) {
        let request = AuthEmailSendReqeustDTO(email: email)
        
        authService.email(type: "PASSWORD_RESET", data: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):

                    self.changePasswordView.emailTextField.setTextFieldInteraction(enabled: false)
                    self.changePasswordView.codeTextField.setTextFieldInteraction(enabled: true)
                    
                    let toastImage = UIImage(named: "Style=Mail") ?? UIImage()
                    CustomToast(containerWidth: 225).show(
                        image: toastImage,
                        message: "인증번호를 발송했어요",
                        font: UIFont.heading3SemiBold()
                    )
                    
                    self.isEnableButtons(self.changePasswordView.sendCodeButton, false)

                case .failure(let error):
                    print("인증 메일 전송 실패: \(error)")
                    self.changePasswordView.emailLabel.isHidden = true  // 기본 라벨 숨기기
                    self.changePasswordView.emailTextField.setError(message: "가입 되지 않은 이메일입니다")
                }
            }
        }
    }
    
    // 인증번호 확인 API
    func callPostVerification(email: String, codeText: String) {
        let request = AuthEmailVerifyRequestDTO(email: email, authCode: codeText)

        authService.verification(data: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                  
                    print("tjdrhdsfdsfsdfdsfsfs")
                    // 인증 성공 시 UI 업데이트 로직 추가
                    self?.handleVerificationSuccess()

                case .failure(let error):
                    print("인증번호 확인 실패: \(error)")
                    self?.changePasswordView.codeTextField.setError(message: "인증번호가 올바르지 않습니다.")
                }
            }
        }
    }
    
    func callGetMeEmail() {
        userService.getMeEmail(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                changePasswordView.emailTextField.textField.text = data.email
                self.emailTextFieldsDidChange()
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    // MARK: - Validation Regex
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    // 비밀번호 정규식 검증
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*]).{8,30}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    //MARK: - Functional
    private func isEnableButtons(_ buttons: AppButton, _ isEnabled: Bool) {
        buttons.setButtonState(
            isEnabled: isEnabled,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
    }
    
    private func setMypageUI() {
        if isMypage {
            callGetMeEmail()
            changePasswordView.codeTextField.setTextFieldInteraction(enabled: true)
            changePasswordView.emailTextField.setTextFieldInteraction(enabled: false)
            changePasswordView.emailTextField.textField.textColor = .gray300
            changePasswordView.emailTextField.textField.backgroundColor = .gray100
            changePasswordView.emailTextField.textField.layer.borderColor = UIColor.gray100.cgColor
            changePasswordView.emailTextField.setHint(message: "가입 시 사용했던 이메일입니다")
        }
    }
    
    private func setEmailFieldDisabledUI() {
        changePasswordView.emailTextField.setTextFieldInteraction(enabled: false)
        changePasswordView.emailTextField.titleLabel.textColor = .gray300
        changePasswordView.emailTextField.textField.textColor = .gray300
        changePasswordView.emailTextField.textField.backgroundColor = .gray100
        changePasswordView.emailTextField.textField.layer.borderColor = UIColor.gray100.cgColor
        changePasswordView.emailTextField.errorLabel.isHidden = true
    }
    
    private func setCodeFieldDisabledUI() {
        changePasswordView.codeTextField.setTextFieldInteraction(enabled: false)
        changePasswordView.codeTextField.titleLabel.textColor = .gray300
        changePasswordView.codeTextField.textField.textColor = .gray300
        changePasswordView.codeTextField.textField.backgroundColor = .gray100
        changePasswordView.codeTextField.textField.layer.borderColor = UIColor.gray100.cgColor
        changePasswordView.codeTextField.errorLabel.isHidden = true
    }
    
    private func handlePasswordChange() {
        guard let email = changePasswordView.emailTextField.textField.text,
              let newPassword = changePasswordView.newPwdTextField.textField.text,
              let passwordCheck = changePasswordView.pwdCheckTextField.textField.text else {
            return
        }
        
        callPatchUserPassword(email, newPassword, passwordCheck)
    }

    // MARK: TextField
    @objc
    private func emailTextFieldsDidChange() {
        // 이메일 유효성 검사
        guard let emailText = changePasswordView.emailTextField.textField.text else { return }
        
        if !isMypage {
            if emailText.isEmpty || isValidEmail(emailText) {
                changePasswordView.emailTextField.clearError()
                changePasswordView.emailLabel.isHidden = false  // 기본 라벨 표시
            } else {
                changePasswordView.emailTextField.setError(message: "올바르지 않은 이메일 형식입니다.")
                changePasswordView.emailLabel.isHidden = true   // 오류 메시지가 표시될 때는 기본 라벨 숨김
            }
        }
       
        let isEmailValid = isValidEmail(emailText)
        isEnableButtons(changePasswordView.sendCodeButton, isEmailValid)
    }
    
    @objc
    private func codeTextFieldsDidChange() {
        guard let codeText = changePasswordView.codeTextField.textField.text else { return }

        if codeText.isEmpty {
            changePasswordView.codeTextField.clearError()
        }

        let isCodeValid = !codeText.isEmpty
        isEnableButtons(changePasswordView.certificationButton, isCodeValid)
    }
    
    @objc
    private func changePasswordTextFieldsDidChange() {
        updatePwdChangeBtnState()
        guard let newPassword = changePasswordView.newPwdTextField.textField.text,
              let confirmPassword = changePasswordView.pwdCheckTextField.textField.text else { return }
        
        //  길이 조건 추가
        let isPasswordValid = isValidPassword(newPassword)
        let isPasswordsMatch = isPasswordValid && newPassword == confirmPassword
        
        isEnableButtons(changePasswordView.changePwdButton, isPasswordsMatch)
        print(isPasswordsMatch)
    }
    
    private func updatePwdChangeBtnState() {
        guard let newPassword = changePasswordView.newPwdTextField.textField.text,
              let confirmPassword = changePasswordView.pwdCheckTextField.textField.text else { return }
        
        // 비어있으면 초기화
        if newPassword.isEmpty && confirmPassword.isEmpty {
            changePasswordView.newPwdTextField.clearError()
            changePasswordView.pwdCheckTextField.clearError()
            return
        }
        
        // 비밀번호 정규식 검사
           if !newPassword.isEmpty {
               if !isValidPassword(newPassword) {
                changePasswordView.newPwdTextField.setError(message: "영문, 숫자, 특수문자를 포함한 8~30자로 입력해주세요")
                changePasswordView.newPwdTextField.titleLabel.textColor = .negative400
                changePasswordView.newPwdTextField.textField.textColor = .negative400
                return
            } else {
                //  길이가 정상 → 기본색으로 돌려주기
                changePasswordView.newPwdTextField.clearError()
                changePasswordView.newPwdTextField.titleLabel.textColor = .gray900
                changePasswordView.newPwdTextField.textField.textColor = .gray900
            }
        }
        
        // 두 비밀번호 비교
        if !confirmPassword.isEmpty {
            if newPassword == confirmPassword {
                changePasswordView.newPwdTextField.setSuccess()
                changePasswordView.pwdCheckTextField.setSuccess()
                
                changePasswordView.newPwdTextField.titleLabel.textColor = .gray900
                changePasswordView.pwdCheckTextField.titleLabel.textColor = .gray900
                changePasswordView.newPwdTextField.textField.textColor = .positive400
                changePasswordView.pwdCheckTextField.textField.textColor = .positive400
                
                changePasswordView.pwdCheckTextField.errorLabel.text = "비밀번호가 일치합니다"
                changePasswordView.pwdCheckTextField.errorLabel.textColor = .positive400
                changePasswordView.pwdCheckTextField.errorLabel.isHidden = false
                changePasswordView.pwdCheckTextField.errorLabelTopConstraint?.update(offset: 4)
            } else {
                changePasswordView.pwdCheckTextField.setError(message: "비밀번호가 일치하지 않습니다")
                changePasswordView.pwdCheckTextField.titleLabel.textColor = .negative400
                changePasswordView.pwdCheckTextField.textField.textColor = .negative400
            }
        }
    }
    
    // MARK: - Event
    @objc
    private func prevVC() {
        if shouldShowExitModal {
            let changePwdErrorVC = ChangePasswordErrorViewController()
            let navController = UINavigationController(rootViewController: changePwdErrorVC)
            navController.modalPresentationStyle = .pageSheet
            presentSheet(navController, heightRatio: 0.37)
        }
        else {
            // 그냥 pop 또는 dismiss
            if let nav = navigationController {
                nav.popViewController(animated: true)
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    
    @objc
    private func sendCodeButtonTapped() {
        guard let emailText = changePasswordView.emailTextField.textField.text,
              !emailText.isEmpty else { return }
        callPostSendCode(email: emailText)
    }
    
    @objc
    private func certificationButtonTapped() {
        guard let emailText = changePasswordView.emailTextField.textField.text,
              let codeText = changePasswordView.codeTextField.textField.text,
              !codeText.isEmpty else { return }
        callPostVerification(email: emailText, codeText: codeText)
    }
    
    private func handleVerificationSuccess() {
        // 인증 성공 시, 인증번호 입력 필드를 비활성화
        self.setCodeFieldDisabledUI()
        self.setEmailFieldDisabledUI()

        // 인증 완료 후 버튼 비활성화
        isEnableButtons(changePasswordView.certificationButton, false)
        isEnableButtons(changePasswordView.sendCodeButton, false)
        
        // 인증 성공 시 토스트 메시지 표시
        let toastImage = UIImage(named: "Style=check") ?? UIImage()
        CustomToast(containerWidth: 258).show(
            image: toastImage,
            message: "인증번호 인증을 완료했어요",
            font: UIFont.heading3SemiBold()
        )
    }
    
    @objc
    private func changePwdButtonTapped() {
        handlePasswordChange()
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
