//
//  ChallengeCompleteViewController.swift
//  GrowIT
//
//  Created by 허준호 on 1/27/25.
//

import UIKit
import Kingfisher

class ChallengeCompleteViewController: UIViewController {
    
    private lazy var challengeCompleteView = ChallengeCompleteView()
    private lazy var challengeService = ChallengeService()
    private var isImageModified: Bool = false
    private var isReviewModified: Bool = false
    private var initialImageData: Data?
    private var newImageData: Data?
    private var initialReview: String?
    private var originalImageUrl: String?
    private var originalImageName: String?
    var challengeId: Int?
    
    
    deinit {
        NotificationCenter.default.removeObserver(self) // 이벤트 감지 해제
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = challengeCompleteView
        view.backgroundColor = .white
        
        setBtnGesture()
        setupDismissKeyboardGesture()
        setupKeyboardNotifications()
        openImagePicker()
        
        challengeCompleteView.reviewContainer.delegate = self
        
        if let id = challengeId{
            print("넘겨받은 id: \(id)")
            getChallenge()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(setImage(_:)), name: NSNotification.Name("ImageSelected"), object: nil)
    }

    
    private func setBtnGesture() {
        challengeCompleteView.challengeExitButton.addTarget(self, action: #selector(exitBtnTapped), for: .touchUpInside)
        challengeCompleteView.challengeUpdateButton.addTarget(self, action: #selector(updateBtnTapped), for: .touchUpInside)
    }
    
    @objc func setImage(_ notification: Notification) {
        if let userInfo = notification.userInfo, let image = userInfo["image"] as? UIImage {
            challengeCompleteView.updateImage(image: image)
            if let originalImage = initialImageData{
                if(originalImage != image.pngData()){
                    print("이미지가 변경되었습니다")
                    isImageModified = true
                    challengeCompleteView.setUpdateBtnActivate(true)
                    newImageData = image.jpegData(compressionQuality: 0.3)
                }else{
                    print("이미지가 변경되지 않았습니다")
                    isImageModified = false
                    challengeCompleteView.setUpdateBtnActivate(isReviewModified)
                }
            }
            
        }
    }
    
    /// 나가기 버튼 이벤트
    @objc private func exitBtnTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 수정하기 버튼 이벤트
    @objc private func updateBtnTapped(){
        if(!isReviewModified && !isImageModified){
            CustomToast().show(image: UIImage(named: "toastAlertIcon") ?? UIImage(), message: "수정사항이 없습니다", font: .heading3SemiBold())
        }else if(isReviewModified && !isImageModified){
            if let id = challengeId, let imageName = originalImageName{
                print("출력한 imageName \(imageName)")
                print("출력한 텍스트 \(challengeCompleteView.reviewContainer.text!)")
                updateChallenge(id: id, imageName: imageName, thoughts: challengeCompleteView.reviewContainer.text ?? "")
            }
        }else{
            if let imageData = newImageData, let id = challengeId{
                ChallengeImageManager(imageData: imageData).uploadImage{ result in
                    DispatchQueue.main.async{
                        
                        switch result{
                        case .success(let imageName):
                            print("updateChallenge 호출 → id:\(id), imageName:\(imageName), thoughts:\(self.challengeCompleteView.reviewContainer.text ?? "nil")")

                            self.updateChallenge(id: id, imageName: imageName, thoughts: self.initialReview ?? "")
                        case .failure(let error):
                            print("S3 이미지 URL 반환 실패: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    // 바깥 영역 터치 시 키보드 숨기기
    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // 키보드 숨김 시 편집모드 종료
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
    
    /// 단일 챌린지 조회 API
    private func getChallenge(){
        challengeService.fetchChallenge(challengeId: challengeId!, completion: { [weak self] result in
            guard let self = self else {return}
            switch result{
            case .success(let data):
                print(data)
                let url = URL(string: data.certificationImageUrl)
                challengeCompleteView.imageContainer.kf.setImage(with: url){ result in
                    switch result{
                    case .success(let data):
                        self.initialImageData = data.image.pngData()
                    case .failure(let error):
                        print("킹피셔 이미지 저장 후 데이터 반환 에러: \(error)")
                    }
                }
                originalImageUrl = data.certificationImageUrl
                originalImageName = data.certificationImageName
                initialReview = data.thoughts
                challengeCompleteView.setupChallenge(challenge: data)
                
            case .failure(let error):
                print("단일 챌린지 조회 오류: \(error)")
            }
            
        })
    }
    
    /// 이미지 선택 방식 모달 열기
    private func openImagePicker() {
        let imageContainerTabGesture = UITapGestureRecognizer(target: self, action: #selector(imageContainerTapped))
        challengeCompleteView.imageContainer.addGestureRecognizer(imageContainerTabGesture)
    }
    
    /// 이미지 영역 터치 이벤트
    @objc private func imageContainerTapped() {
        let challengeImageModalController = ChallengeImageModalController()
        challengeImageModalController.modalPresentationStyle = .pageSheet
        
        presentSheet(challengeImageModalController, heightRatio: 0.39)
    }
    
    /// 챌린지 수정 API
    private func updateChallenge(id: Int, imageName: String, thoughts: String){
        challengeService.patchChallenge(challengeId: id, data: ChallengeRequestDTO(certificationImageName: imageName, thoughts: thoughts), completion: { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let data):
                print(data)
                CustomToast().show(image: UIImage(named: "notcheckedBox") ?? UIImage(), message: "챌린지를 수정했어요", font: .heading3SemiBold())
                dismiss(animated: true)
            case .failure(let error):
                print("챌린지 수정 에러:\(error)")
            }
             
        })
    }
}

extension ChallengeCompleteViewController: UITextViewDelegate{
    
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
        let textLength = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).count
        
        if(textLength == 0){
            challengeCompleteView.validateTextView(errorMessage: "챌린지 한줄소감은 필수로 입력해야 합니다", textColor: .negative400, bgColor: .negative50, borderColor: .negative400, hintColor: .negative400)
            challengeCompleteView.setUpdateBtnActivate(false)
        }else if(textLength < 50 || textLength > 100){
            challengeCompleteView.validateTextView(errorMessage: "챌린지 한줄소감은 50자 이상 100자 이하 적어야 합니다", textColor: .negative400, bgColor: .negative50, borderColor: .negative400, hintColor: .negative400)
            challengeCompleteView.setUpdateBtnActivate(false)
        }else{
            challengeCompleteView.validateTextView(errorMessage: "챌린지 한줄소감을 50자 이상 적어주세요", textColor: .gray900, bgColor: .white, borderColor:
                .black.withAlphaComponent(0.1), hintColor: .gray500)
            challengeCompleteView.setUpdateBtnActivate(false)
            if(initialReview != textView.text){
                initialReview = textView.text
                isReviewModified = true
                challengeCompleteView.setUpdateBtnActivate(true)
            }
        }
        
        self.view.layoutIfNeeded()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let textLength = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).count
        
        if(textLength == 0){
            challengeCompleteView.reviewContainer.text = "챌린지 소감을 간단하게 입력해 주세요"
            challengeCompleteView.reviewContainer.textColor = .negative400
        }
    }
}

