//
//  VoiceDiaryFixViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/16/25.
//

import UIKit

class DiaryPostFixViewController: UIViewController {
    
    // MARK: Properties
    let text: String
    let date: String
    let diaryId: Int
    let diaryPostFixView = DiaryPostFixView()
    private let diaryService = DiaryService()
    var onDismiss: (() -> Void)?
    var isFixing: Bool = false
    
    init(text: String, date: String, diaryId: Int) {
        self.text = text
        self.date = date
        self.diaryId = diaryId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegate()
        setupActions()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // 터치 이벤트가 다른 뷰에도 전달되도록 함
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: Setup UI
    private func setupUI() {
        self.view = diaryPostFixView
        
        diaryPostFixView.configure(text: text, date: date)
    }
    
    // MARK: Setup Actions
    private func setupActions() {
        diaryPostFixView.cancelButton.addTarget(self, action: #selector(prevVC), for: .touchUpInside)
        diaryPostFixView.fixButton.addTarget(self, action: #selector(nextVC), for: .touchUpInside)
        
        let labelAction = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        diaryPostFixView.deleteLabel.addGestureRecognizer(labelAction)
    }
    
    // MARK: Setup Delegate
    private func setupDelegate() {
        diaryPostFixView.textView.delegate = self
    }
    
    // MARK: @objc methods
    @objc func prevVC() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func nextVC() {
        callPatchFixDiary()
    }
    
    @objc func labelTapped() {
        let nextVC = DiaryDeleteViewController(diaryId: diaryId)
        
        nextVC.onDismiss = { [weak self] in
            self?.onDismiss?() // ✅ `DiaryAllViewController`의 `callGetAllDiaries()` 호출
        }
        
        let navController = UINavigationController(rootViewController: nextVC)
        navController.modalPresentationStyle = .fullScreen
        
        presentSheet(navController, heightRatio: 0.37)    }
    
    // MARK: Setup APIs
    private func getUserContent() -> DiaryPatchDTO {
        let userContent: DiaryPatchDTO = DiaryPatchDTO(content: diaryPostFixView.textView.text)
        return userContent
    }
    
    
    private func callPatchFixDiary() {
        guard !isFixing else { return }
        isFixing = true
        diaryService.patchFixDiary(
            diaryId: diaryId,
            data: getUserContent(),
            completion: { [weak self] result in
                guard let self = self else { return }
                self.isFixing = false
                switch result {
                case .success(let data):
                    print("Success: \(data)")
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .diaryReloadNotification, object: nil)
                        CustomToast(containerWidth: 195).show(image: UIImage(named: "toastIcon") ?? UIImage(), message: "일기를 수정했어요", font: .heading3SemiBold())
                        self.dismiss(animated: true) {
                            self.onDismiss?()  // 모달 해제 후 onDismiss 호출
                        }
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
    }
}

extension DiaryPostFixViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let changedState = textView.text == self.text ? false : true
        diaryPostFixView.fixButton.setButtonState(
            isEnabled: changedState,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400)
    }
}
