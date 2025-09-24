//
//  ChallengeVerifyViewController.swift
//  GrowIT
//
//  Created by 허준호 on 1/24/25.
//

import UIKit
import Photos
import SnapKit

class ChallengeVerifyViewController: UIViewController {
    
    private lazy var challengeVerifyView = ChallengeVerifyView() // 챌린지 인증화면 뷰
    private lazy var navigationBarManager = NavigationManager()
    private let imagePicker = UIImagePickerController() // 인증샷 이미지 피커
    private var reviewLength: Int = 0 // 작성한 한줄소감 글자 수
    private var uploadImage: UIImage? // 인증샷 이미지
    private var isImageSelected: Bool = false // 이미지 인증샷 유무
    private var isReviewValidate: Bool = false // 한줄소감 유효성 검증
    private lazy var challengeService = ChallengeService()
    var challenge: UserChallenge?
    private lazy var imageData: Data? = nil
    var review: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = challengeVerifyView
        view.backgroundColor = .gray50
        
        setupNavigationBar() // 네비게이션 바 설정 함수
        openImagePicker() // 이미지 선택 관련 함수
        setupDismissKeyboardGesture() // 키보드 해제 함수
        
        challengeVerifyView.reviewTextView.delegate = self
        challengeVerifyView.challengeVerifyButton.addTarget(self, action: #selector(challengeVerifyButtonTapped), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleImage(_:)), name: NSNotification.Name("ImageSelected"), object: nil)
        
        setupInitialTextViewState()
        
        challengeVerifyView.setChallengeName(name: challenge?.title ?? "")
        challengeVerifyView.setContent(name: challenge?.content ?? "")
        
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
    
    init(challenge: UserChallenge?){
        super.init(nibName: nil, bundle: nil)
        if let challenge = challenge {
            self.challenge = challenge
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupInitialTextViewState() {
        challengeVerifyView.reviewTextView.text = "챌린지 소감을 간단하게 입력해 주세요"
        challengeVerifyView.reviewTextView.setLineSpacing(spacing: 4, font: .body1Medium(), color: .gray300)
    }
    
    @objc func handleImage(_ notification: Notification) {
        if let userInfo = notification.userInfo, let image = userInfo["image"] as? UIImage {
            isImageSelected = true
            imageData = image.jpegData(compressionQuality: 0.3)
            challengeVerifyView.imageUploadCompleted(image)
            challengeVerifyView.imageContainer.superview?.layoutIfNeeded()
            
            // ✅ 소감까지 유효하다면 버튼 활성화
            if isReviewValidate {
                challengeVerifyView.challengeVerifyButton.backgroundColor = .black
                challengeVerifyView.challengeVerifyButton.setTitleColor(.white, for: .normal)
            }
        }
    }


    private func setupNavigationBar() {
        navigationBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(prevVC),
            tintColor: .black
        )
        
        navigationBarManager.setTitle(
            to: navigationItem,
            title: "챌린지 인증하기",
            textColor: .gray900,
            font: .heading1Bold()
        )
        
        // 네비게이션 바 스타일 설정
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white  // 배경색을 흰색으로 설정

        // iOS 15 이상에서는 scrollEdgeAppearance도 설정해야 함
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func openImagePicker() {
        //imagePicker.delegate = self
        //imagePicker.sourceType = .photoLibrary
        
        let imageContainerTabGesture = UITapGestureRecognizer(target: self, action: #selector(imageContainerTapped))
        challengeVerifyView.imageContainer.addGestureRecognizer(imageContainerTabGesture)
    }
    
    /// 뒤로가기 버튼 이벤트
    @objc private func prevVC() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 이미지 영역 터치 이벤트
    @objc private func imageContainerTapped() {
        let challengeImageModalController = ChallengeImageModalController()
        challengeImageModalController.modalPresentationStyle = .pageSheet
        
        presentSheet(challengeImageModalController, heightRatio: 0.38)
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
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let scrollView = challengeVerifyView.scrollView
        let bottomInset = keyboardFrame.height + 30 // 버튼과 간격 여유

        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset

        // TextView가 가려지지 않게 스크롤
        let textViewFrame = challengeVerifyView.reviewTextView.convert(challengeVerifyView.reviewTextView.bounds, to: scrollView)
        scrollView.scrollRectToVisible(textViewFrame, animated: true)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        let scrollView = challengeVerifyView.scrollView
        UIView.animate(withDuration: 0.25) {
            scrollView.contentInset.bottom = 0
            scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }





    
//    @objc private func keyboardWillShow(_ notification: Notification) {
//        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
//
//        // 레이아웃 최신화
//        view.layoutIfNeeded()
//        
//        let textViewMaxY = challengeVerifyView.reviewTextView.convert(challengeVerifyView.reviewTextView.bounds, to: view).maxY
//        let keyboardY = view.frame.height - keyboardFrame.height
//        
//        if textViewMaxY > keyboardY {
//            let diff = textViewMaxY - keyboardY + 16
//            UIView.animate(withDuration: 0.25) {
//                self.view.transform = CGAffineTransform(translationX: 0, y: -diff)
//            }
//        } else {
//            UIView.animate(withDuration: 0.25) {
//                self.view.transform = .identity
//            }
//        }
//    }
//
//
//    @objc private func keyboardWillHide(_ notification: Notification) {
//        challengeVerifyView.challengeVerifyButton.snp.updateConstraints {
//            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
//        }
//        UIView.animate(withDuration: 0.25) {
//            self.view.layoutIfNeeded()
//        }
//    }

    /// 인증하기 버튼 터치 이벤트
    /// 인증하기 버튼 터치 이벤트
    @objc private func challengeVerifyButtonTapped() {
        print("verify button tapped")
        
        // 1. 이미지 선택 안됨
        if !isImageSelected {
            CustomToast(containerWidth: 244).show(
                image: UIImage(named: "challengeToastIcon") ?? UIImage(),
                message: "인증샷을 업로드해 주세요",
                font: .heading3SemiBold()
            )
            return
        }
        
        // 2. 이미지 선택했지만 소감이 유효하지 않음
        if !isReviewValidate {
            challengeVerifyView.validateTextView(
                errorMessage: "챌린지 한줄소감은 50자 이상 100자 이하 적어야 합니다",
                textColor: .negative400,
                bgColor: .negative50,
                borderColor: .negative400,
                hintColor: .negative400
            )
            return
        }
        
        // 3. 이미지도 있고 소감도 유효 → API 호출
        review = challengeVerifyView.reviewTextView.text
        getPresignedUrl()
    }

    
    /// S3 Presigned URL 요청 API
    private func getPresignedUrl(){
        challengeService.postPresignedUrl(data: PresignedUrlRequestDTO(contentType: "image/jpeg"), completion: { [weak self] result in
            guard let self = self else {return}
            switch result{
            case .success(let data):
                
                if let image = imageData{
                    putImageToS3(presignedUrl: data.presignedUrl, imageData: image, fileName: data.fileName)
                }
               
            case .failure(let error):
                print("Presigned URl 요청 에러 \(error)")
            }
        })
    }
    
    /// S3에 이미지 업로드 API
    private func putImageToS3(presignedUrl: String, imageData: Data, fileName: String){
        var request = URLRequest(url: URL(string: presignedUrl)!)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type") // JPEG로 변경
        request.httpBody = imageData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse,
                  error == nil else {
                print("Error during the upload: \(error!.localizedDescription)")
                return
            }

            if response.statusCode == 200 {
                self.saveChallengeVerify(fileName: fileName)
            } else {
                print("Upload failed with status: \(response.statusCode)")
            }
        }
        task.resume()
    }

    
    /// 챌린지 인증 저장 API
    private func saveChallengeVerify(fileName: String){
        challengeService.postProveChallenge(challengeId: challenge?.id ?? 0, data: ChallengeRequestDTO(certificationImageName: fileName, thoughts: review), completion: { [weak self] result in
            guard let self = self else {return}
            switch result{
            case .success(let data):
                DispatchQueue.main.async {
                    
                    NotificationCenter.default.post(name: .challengeReloadNotification, object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name("challengeVerifyCompleted"), object: nil, userInfo: ["granted": data.creditInfo.granted])
                    self.navigationController?.popViewController(animated: false)
                }
            case .failure(let error):
                print("챌린지 인증 저장 에러: \(error)")
            }
        })
    }
}

extension ChallengeVerifyViewController: UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // "Done" (엔터) 입력 시 키보드 내리기
        if text == "\n" {
            //textView.resignFirstResponder()
            return true
        }
        
        // 현재 텍스트와 입력할 텍스트의 합으로 새 길이 계산
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 100 // 100자 제한
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "챌린지 소감을 간단하게 입력해 주세요"{
                textView.text = nil
                textView.textColor = .gray900
            }
        }
    
    func textViewDidChange(_ textView: UITextView) {
        reviewLength = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
        
        if reviewLength < 50 || reviewLength > 100 {
            isReviewValidate = false
            challengeVerifyView.validateTextView(
                errorMessage: "챌린지 한줄소감은 50자 이상 100자 이하 적어야 합니다",
                textColor: .negative400,
                bgColor: .negative50,
                borderColor: .negative400,
                hintColor: .negative400
            )
        } else {
            isReviewValidate = true
            challengeVerifyView.validateTextView(
                errorMessage: "챌린지 한줄소감은 50자 이상 100자 이하 적어야 합니다",
                textColor: .gray900,
                bgColor: .white,
                borderColor: .black.withAlphaComponent(0.1),
                hintColor: .gray500
            )
            
            // ✅ 이미지까지 있으면 버튼 활성화
            if isImageSelected {
                challengeVerifyView.challengeVerifyButton.backgroundColor = .black
                challengeVerifyView.challengeVerifyButton.setTitleColor(.white, for: .normal)
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        reviewLength = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
        
        if(reviewLength == 0){
            isReviewValidate = false
            challengeVerifyView.reviewTextView.text = "챌린지 소감을 간단하게 입력해 주세요"
            challengeVerifyView.validateTextView(errorMessage: "챌린지 한줄소감은 필수로 입력해야 합니다", textColor: .negative400, bgColor: .negative50, borderColor: .negative400, hintColor: .negative400)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 키보드 숨기기
        return true
    }
    
    
}

extension UIResponder {
    
    private struct Static {
        static weak var responder: UIResponder?
    }
    
    static var currentResponder: UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil)
        return Static.responder
    }
    
    @objc private func _trap() {
        Static.responder = self
    }
}
