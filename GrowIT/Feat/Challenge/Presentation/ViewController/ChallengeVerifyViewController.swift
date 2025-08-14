//
//  ChallengeVerifyViewController.swift
//  GrowIT
//
//  Created by 허준호 on 1/24/25.
//

import UIKit
import Combine

final class ChallengeVerifyViewController: UIViewController {
    private lazy var challengeVerifyView = ChallengeVerifyView()
    private lazy var navigationBarManager = NavigationManager()
    private let viewModel: ChallengeVerifyViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: ChallengeVerifyViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = challengeVerifyView
        view.backgroundColor = .gray50
        
        setupNavigationBar()
        bindViewModel()
        setupUIEvents()
        setupDismissKeyboardGesture()
        setupKeyboardNotifications()
        setupInitialTextViewState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        challengeVerifyView.reviewTextView.resignFirstResponder()
    }
    
    private func setupInitialTextViewState() {
        challengeVerifyView.reviewTextView.text = ChallengeVerifyViewModel.placeholder
        challengeVerifyView.reviewTextView.textColor = .gray300
        challengeVerifyView.reviewTextView.setLineSpacing(
            spacing: 4, font: .body1Medium(), color: .gray300
        )
        challengeVerifyView.validateTextView(
            errorMessage: "챌린지 한줄소감을 50자 이상 적어주세요",
            textColor: .gray300, bgColor: .white, borderColor: .gray300, hintColor: .gray300
        )
        challengeVerifyView.setChallengeName(name: viewModel.challenge?.title ?? "")
        viewModel.isPlaceholder = true
        viewModel.reviewText = ""
    }
    
    
    private func bindViewModel() {
        // 버튼 상태
        viewModel.$isButtonEnabled
            .sink { [weak self] enabled in
                self?.challengeVerifyView.challengeVerifyButton.setButtonState(
                    isEnabled: enabled,
                    enabledColor: .black,
                    disabledColor: .gray100,
                    enabledTitleColor: .white,
                    disabledTitleColor: .gray400
                )
            }.store(in: &cancellables)
        
        // 에러 메시지 및 텍스트뷰 스타일
        viewModel.$errorMessage
            .sink { [weak self] msg in
                guard let self = self else { return }
                if let msg = msg {
                    self.challengeVerifyView.validateTextView(
                        errorMessage: msg,
                        textColor: .negative400, bgColor: .negative50,
                        borderColor: .negative400, hintColor: .negative400
                    )
                } else {
                    self.challengeVerifyView.validateTextView(
                        errorMessage: "챌린지 한줄소감을 50자 이상 적어 주세요",
                        textColor: .gray900, bgColor: .white,
                        borderColor: .gray300, hintColor: .gray300
                    )
                }
            }.store(in: &cancellables)
        
        // 토스트 (이미지 없을 때)
        viewModel.$showImageToast
            .filter { $0 }
            .sink { _ in
                CustomToast(containerWidth: 244).show(
                    image: UIImage(named: "challengeToastIcon") ?? UIImage(),
                    message: "인증샷을 업로드해 주세요",
                    font: .heading3SemiBold()
                )
            }.store(in: &cancellables)
        
        // 인증 성공
        viewModel.$success
            .filter { $0 }
            .sink { [weak self] _ in
                NotificationCenter.default.post(name: .challengeStatusReload, object: nil)
                self?.navigationController?.popViewController(animated: false)
                CustomToast(containerWidth: 244).show(
                    image: UIImage(named: "challengeToastIcon") ?? UIImage(),
                    message: "챌린지 인증을 완료했어요",
                    font: .heading3SemiBold()
                )
            }.store(in: &cancellables)
        
        // 이미지 선택
        viewModel.$image
            .sink { [weak self] img in
                if let img = img {
                    self?.challengeVerifyView.imageUploadCompleted(img)
                }
            }
            .store(in: &cancellables)
        
    }
    
    private func setupNavigationBar() {
        navigationBarManager.addBackButton(
            to: navigationItem, target: self, action: #selector(prevVC), tintColor: .black
        )
        navigationBarManager.setTitle(
            to: navigationItem,
            title: "챌린지 인증하기",
            textColor: .gray900,
            font: .heading1Bold()
        )
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupUIEvents() {
        challengeVerifyView.challengeVerifyButton.addTarget(self, action: #selector(verifyButtonTapped), for: .touchUpInside)
        challengeVerifyView.reviewTextView.delegate = self
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        challengeVerifyView.imageContainer.addGestureRecognizer(imageTap)
    }
    
    @objc private func verifyButtonTapped() {
        viewModel.verify()
    }
    
    @objc private func imageTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @objc private func prevVC() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 바깥 영역 터치 시 키보드 숨기기
    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// 키보드 감지시 수행하는 함수
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// 키보드가 나타나면 키보드 높이만큼 화면 올리기
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    /// 키보드 내려가면 원래대로 복구
    @objc private func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

extension ChallengeVerifyViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if viewModel.isPlaceholder {
            textView.text = ""
            textView.textColor = .gray900
            viewModel.isPlaceholder = false
        }
        viewModel.resetErrorMessage()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text ?? ""
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = ChallengeVerifyViewModel.placeholder
            textView.textColor = .gray300   // <-- 반드시 회색으로 지정
            viewModel.isPlaceholder = true
            viewModel.reviewText = ""
            viewModel.resetErrorMessage()
        } else {
            // 입력이 있을 때는 검정색
            textView.textColor = .gray900
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            let plainText = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            if viewModel.isPlaceholder || plainText.isEmpty {
                textView.text = ChallengeVerifyViewModel.placeholder
                textView.textColor = .gray300
                viewModel.isPlaceholder = true
                viewModel.reviewText = ""
                viewModel.resetErrorMessage()
                return false
            }
            viewModel.reviewText = plainText
            viewModel.validateReviewText()
            return false
        } else {
            if viewModel.isPlaceholder {
                viewModel.isPlaceholder = false
                textView.text = ""
                textView.textColor = .gray900
            }
            if let textRange = Range(range, in: textView.text ?? "") {
                let updatedText = (textView.text ?? "").replacingCharacters(in: textRange, with: text)
                viewModel.reviewText = updatedText
            }
            return true
        }
    }
}





extension ChallengeVerifyViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImg = info[.originalImage] as? UIImage {
            viewModel.image = selectedImg
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
