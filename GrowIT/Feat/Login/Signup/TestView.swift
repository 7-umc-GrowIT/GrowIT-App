//import UIKit
//
//class TestView: UIView {
//
//    // MARK: - Components
//    let emailField = TextFieldWithButton(
//        textfieldTitle: "이메일",
//        placeholder: "이메일을 입력하세요",
//        buttonTitle: "전송"
//    )
//
//    let codeField = TextFieldWithButton(
//        textfieldTitle: "인증번호",
//        placeholder: "인증번호를 입력하세요",
//        buttonTitle: "확인"
//    )
//
//    // MARK: - Init
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .white
//        addViews()
//        setupConstraints()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func addViews() {
//        addSubviews([emailField, codeField])
//    }
//
//    private func setupConstraints() {
//        emailField.snp.makeConstraints {
//            $0.top.equalTo(safeAreaLayoutGuide).offset(40)
//            $0.leading.trailing.equalToSuperview().inset(20)
//        }
//
//        codeField.snp.makeConstraints {
//            $0.top.equalTo(emailField.snp.bottom).offset(40)
//            $0.leading.trailing.equalToSuperview().inset(20)
//        }
//    }
//}
//
////MARK: --
//
//class TestViewController: UIViewController {
//
//    private lazy var testView = TestView().then {
//        // 버튼 액션 연결
//        $0.emailField.actionButton.addTarget(self, action: #selector(sendCodeTapped), for: .touchUpInside)
//        $0.codeField.actionButton.addTarget(self, action: #selector(verifyCodeTapped), for: .touchUpInside)
//
//        // 텍스트필드 이벤트 연결
//        $0.emailField.innerTextField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
//        $0.codeField.innerTextField.addTarget(self, action: #selector(codeChanged), for: .editingChanged)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view = testView
//    }
//
//    // MARK: - Actions
//    @objc private func sendCodeTapped() {
//        print("전송 버튼 눌림! 이메일:", testView.emailField.text ?? "")
//    }
//
//    @objc private func verifyCodeTapped() {
//        print("확인 버튼 눌림! 코드:", testView.codeField.text ?? "")
//    }
//
//    @objc private func emailChanged() {
//        guard let text = testView.emailField.text else { return }
//        let isValid = text.contains("@") // 임시 간단 검증
//        testView.emailField.setState(isValid ? .success("올바른 이메일입니다.") : .error("잘못된 이메일 형식"))
//        testView.emailField.setButtonState(isEnabled: isValid)
//    }
//
//    @objc private func codeChanged() {
//        guard let text = testView.codeField.text else { return }
//        let isValid = text.count >= 4
//        testView.codeField.setState(isValid ? .success("올바른 코드입니다.") : .error("코드를 4자리 이상 입력하세요"))
//        testView.codeField.setButtonState(isEnabled: isValid)
//    }
//}
////
////  EmailVerificationViewController.swift
////  GrowIT
////
////  Created by 강희정 on 1/25/25.
////
//
//import UIKit
//import Foundation
//
//class EmaiㅇlVerificationViewController: UIViewController {
//    // MARK: - Properties
//    private let navigationBarManager = NavigationManager()
//    let authService = AuthService()
//
//    var agreeTerms: [UserTermDTO] = []
//    private var isEmailFieldDisabled = false
//    // 인증번호 비교용 이메일
//    private var email1: String = ""
//
//    // MARK: - View
//    private lazy var emailVerificationView = EmailVerificationView().then {
//        // Buttons
//        $0.sendCodeButton.addTarget(self, action: #selector(sendCodeButtonTapped), for: .touchUpInside)
//        $0.certificationButton.addTarget(self, action: #selector(certificationButtonTapped), for: .touchUpInside)
//
//        //  Textfields
//        $0.emailTextField.textField.addTarget(self, action: #selector(updateSendCodeButtonState), for: .editingChanged)
//        $0.codeTextField.textField.addTarget(self, action: #selector(updateCertificationButtonState), for: .editingChanged)
//
//        $0.nextButton.addTarget(self, action: #selector(nextButtonTap), for: .touchUpInside)
//    }
//
//    // MARK: - init
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view = emailVerificationView
//
//        setupNavigationBar()
//        setupActions()
//
//        emailVerificationView.nextButton.isEnabled = false
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//            view.addGestureRecognizer(tapGesture)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: false)
//    }
//
//    // MARK: - Setup UI
//    private func setupNavigationBar() {
//        navigationBarManager.setTitle(
//            to: self.navigationItem,
//            title: "회원가입",
//            textColor: .gray900,
//            font: .heading1Bold()
//        )
//
//        navigationBarManager.addBackButton(
//            to: navigationItem,
//            target: self,
//            action: #selector(prevVC)
//        )
//    }
//
//    // MARK: - Setup Actions
//    private func setupActions() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tapGesture)
//    }
//
//    // MARK: - NetWork
//    func callPostVerification(codeText: String) {
//        let request = EmailVerifyRequest(email: email1, authCode: codeText)
//
//        authService.verification(data: request) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    print("인증번호 확인 성공 메시지: \(response.message)")
//
//                    // 인증 성공 UI 업데이트
//                    self.handleVerificationSuccess()
//
//                case .failure(let error):
//                    print("인증번호 확인 실패: \(error)")
//
//                    // 서버 응답에서 인증 실패 메시지를 확인하고 필드 업데이트
//                    self.emailVerificationView.codeTextField.setError(message: "인증번호가 올바르지 않습니다.")
//                }
//            }
//        }
//    }
//
//    func callPostSendCode(email: String) {
//        let request = SendEmailVerifyRequest(email: email)
//        self.email1 = email
//        authService.email(type: "SIGNUP", data: request) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    print("인증 메일 전송 성공 이메일: \(response.email)")
//                    print("응답 메시지: \(response.message)")
//
//                    self.isEmailFieldDisabled = true
//
//                    ToastSecond.show(
//                        image: UIImage(named: "Style=Mail") ?? UIImage(),
//                        message: "인증번호를 발송했어요",
//                        font: .heading3SemiBold(),
//                        in: self.view
//                    )
//
//                case .failure(let error):
//                    print("인증 메일 전송 실패: \(error)")
//
//                    if case .serverError(let statusCode, let message) = error,
//                       statusCode == 409 {
//                        // 👉 이미 가입된 이메일일 때 에러 처리
//                        self.emailVerificationView.emailTextField.setError(message: "이미 가입된 이메일입니다.")
//                    }
//                }
//            }
//        }
//    }
//
//    // MARK: - TextField Change Handler
//    // 인증번호 전송 버튼
//    @objc
//    private func updateSendCodeButtonState() {
//
//        // 이메일 유효성 검사
//        guard let emailText = emailVerificationView.emailTextField.textField.text else { return }
//        let isEmailValid = isValidEmail(emailText)
//
//        if emailText.isEmpty || isEmailValid {
//            emailVerificationView.emailTextField.clearError()
//        } else {
//            emailVerificationView.emailTextField.setError(message: "올바르지 않은 이메일 형식입니다.")
//        }
//
//        // 버튼 활성화 상태 관리
//        isEnableButtons(emailVerificationView.sendCodeButton, isEmailValid)
//    }
//
//    // 코드인증 버튼
//    @objc
//    private func updateCertificationButtonState() {
//        guard let codeText = emailVerificationView.codeTextField.textField.text else { return }
//        emailVerificationView.codeTextField.clearError() // ???????
//
//        let isCodeValid = !codeText.isEmpty
//
//        // 버튼 활성화 상태 관리
//        isEnableButtons(emailVerificationView.certificationButton, isCodeValid)
//    }
//
//    // MARK: - Helper
//    private func isValidEmail(_ email: String) -> Bool {
//        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
//        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
//    }
//
//    // 인증 성공 후 아예 비활성화
//    private func setCodeFieldDisabledUI() {
//        emailVerificationView.codeTextField.setTextFieldInteraction(enabled: false)
//        emailVerificationView.codeTextField.titleLabel.textColor = .gray300
//        emailVerificationView.codeTextField.textField.textColor = .gray300
//        emailVerificationView.codeTextField.textField.backgroundColor = .gray100
//    }
//
//    // 인증 성공 시 처리
//    private func handleVerificationSuccess() {
//        // 인증번호 필드 비활성화
//        setCodeFieldDisabledUI()
//
//        // 이메일 필드 Success 상태로 변경
//        self.emailVerificationView.emailTextField.setTextFieldInteraction(enabled: false)
//        self.emailVerificationView.emailTextField.setSuccess()
//
//        // 성공 메시지 표시
//        self.emailVerificationView.emailTextField.errorLabel.text = "이메일 인증이 완료되었습니다."
//        self.emailVerificationView.emailTextField.errorLabel.textColor = UIColor.positive400
//        self.emailVerificationView.emailTextField.errorLabel.isHidden = false
//        self.emailVerificationView.emailTextField.errorLabelTopConstraint?.update(offset: 4)
//
//        ToastSecond.show(image: UIImage(named: "Style=check") ?? UIImage(), message: "인증번호 인증을 완료했어요", font: .heading3SemiBold(), in: self.view)
//
//        // 버튼 상태 업데이트
//        isEnableButtons(emailVerificationView.certificationButton, false)
//        isEnableButtons(emailVerificationView.sendCodeButton, false)
//        isEnableButtons(emailVerificationView.nextButton, true)
//    }
//
//    private func isEnableButtons(_ buttons: AppButton, _ isEnabled: Bool) {
//        buttons.setButtonState(
//            isEnabled: isEnabled,
//            enabledColor: .black,
//            disabledColor: .gray100,
//            enabledTitleColor: .white,
//            disabledTitleColor: .gray400
//        )
//    }
//
//    // MARK: - Actions
//    // 중간에 나갈 경우 모달
//    @objc
//    private func prevVC() {
//        let emailErrorVC = EmailVerificationErrorViewController()
//        let navController = UINavigationController(rootViewController: emailErrorVC)
//        navController.modalPresentationStyle = .pageSheet
//        presentSheet(navController, heightRatio: 314/932)
//    }
//
//    @objc
//    private func sendCodeButtonTapped() {
//        guard let emailText = emailVerificationView.emailTextField.textField.text,
//              !emailText.isEmpty else {
//            print("이메일 입력 필요")
//            return
//        }
//        callPostSendCode(email: emailText)
//
//        //  버튼 누르자마자 비활성화
//        view.endEditing(true)
//        self.emailVerificationView.emailTextField.clearButton.isHidden = true
//        isEnableButtons(emailVerificationView.sendCodeButton, false)
//    }
//
//    @objc
//    private func certificationButtonTapped() {
//        guard let codeText = emailVerificationView.codeTextField.textField.text, !codeText.isEmpty else { return }
//        callPostVerification(codeText: codeText)
//    }
//
//    @objc
//    func nextButtonTap() {
//        let userInfoVC = UserInfoInputViewController()
//
//        // 약관 동의 데이터를 올바르게 전달
//        userInfoVC.email = email1
//        userInfoVC.isVerified = true
//        userInfoVC.agreeTerms = agreeTerms
//
//        print("이메일 인증에서 전달된 약관 목록: \(agreeTerms)")
//
//        self.navigationController?.pushViewController(userInfoVC, animated: true)
//    }
//
//    @objc
//    private func dismissKeyboard() {
//        view.endEditing(true)
//    }
//}
