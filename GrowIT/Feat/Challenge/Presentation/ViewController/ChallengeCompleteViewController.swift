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
                    newImageData = image.pngData()
                }else{
                    print("이미지가 변경되지않았습니다")
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
            if let id = challengeId, let url = originalImageUrl{
                print("출력한 url \(url)")
                print("출력한 텍스트 \(challengeCompleteView.reviewContainer.text!)")
                updateChallenge(id: id, url: String(url), thoughts: challengeCompleteView.reviewContainer.text!)
            }
        }else{
            if let imageData = newImageData, let id = challengeId{
                ChallengeImageManager(imageData: imageData).uploadImage{ result in
                    DispatchQueue.main.async{
                        switch result{
                        case .success(let url):
                            self.updateChallenge(id: id, url: url, thoughts: self.challengeCompleteView.reviewContainer.text)
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
        
        if let sheet = challengeImageModalController.sheetPresentationController {
                    
            //지원할 크기 지정
            if #available(iOS 16.0, *){
                sheet.detents = [.custom{ _ in
                    360.0
                }]
            }else{
                sheet.detents = [.medium(), .large()]
            }
            
            // 시트의 상단 둥근 모서리 설정
            if #available(iOS 15.0, *) {
                sheet.preferredCornerRadius = 40
            }
            
            //크기 변하는거 감지
            sheet.delegate = self
           
            //시트 상단에 그래버 표시 (기본 값은 false)
            sheet.prefersGrabberVisible = false
            
            //처음 크기 지정 (기본 값은 가장 작은 크기)
            sheet.selectedDetentIdentifier = .large
        }
        
        self.present(challengeImageModalController, animated: true, completion: nil)
    }
    
    /// 챌린지 수정 API
    private func updateChallenge(id: Int, url: String, thoughts: String){
        challengeService.patchChallenge(challengeId: id, data: ChallengeRequestDTO(certificationImageUrl: url, thoughts: thoughts), completion: { [weak self] result in
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

extension ChallengeCompleteViewController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        //크기 변경 됐을 경우
        print(sheetPresentationController.selectedDetentIdentifier == .large ? "large" : "medium")
    }
}

extension ChallengeCompleteViewController: UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // "Done" 버튼을 눌렀을 때 키보드 내리기
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "챌린지 소감을 간단하게 입력해 주세요"{
            textView.text = nil
            textView.textColor = .gray900
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let textLength = textView.text.count
        
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
                isReviewModified = true
                challengeCompleteView.setUpdateBtnActivate(true)
            }
        }
        
        self.view.layoutIfNeeded()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let textLength = textView.text.count
        
        if(textLength == 0){
            challengeCompleteView.reviewContainer.text = "챌린지 소감을 간단하게 입력해 주세요"
            challengeCompleteView.reviewContainer.textColor = .negative400
        }
    }
}

