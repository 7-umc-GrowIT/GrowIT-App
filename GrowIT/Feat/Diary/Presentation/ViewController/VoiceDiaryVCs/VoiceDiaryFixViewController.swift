//
//  VoiceDiaryFixViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/16/25.
//

import UIKit

protocol VoiceDiaryFixDelegate: AnyObject {
    func didModifyDiary(with newText: String)
}

class VoiceDiaryFixViewController: UIViewController {
    weak var delegate: VoiceDiaryFixDelegate?
    
    // MARK: Properties
    let text: String
    let voiceDiaryFixView = VoiceDiaryFixView()
    
    var diaryId = 0
    let diaryService = DiaryService()
    
    var recommendedChallenges: [RecommendedDiaryChallengeDTO] = []
    var emotionKeywords: [EmotionKeyword] = []
    
    var isFixing: Bool = false
    
    var onChanged: ((String) -> Void)?
    
    init(text: String) {
        self.text = text
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
    }
    
    // MARK: Setup UI
    private func setupUI() {
        view.addSubview(voiceDiaryFixView)
        voiceDiaryFixView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        voiceDiaryFixView.configure(text: text)
    }
    
    // MARK: Setup Actions
    private func setupActions() {
        voiceDiaryFixView.cancelButton.addTarget(self, action: #selector(prevVC), for: .touchUpInside)
        voiceDiaryFixView.fixButton.addTarget(self, action: #selector(nextVC), for: .touchUpInside)
    }
    
    // MARK: Setup Delegate
    private func setupDelegate() {
        voiceDiaryFixView.textView.delegate = self
    }
    
    // MARK: @objc methods
    @objc func prevVC() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func nextVC() {
        fixDiary()
    }
    
    private func fixDiary() {
        guard !isFixing else { return }
        isFixing = true
        diaryService.patchFixDiary(diaryId: diaryId, data: DiaryPatchDTO(content: self.voiceDiaryFixView.textView.text)) { result in
            switch result {
            case .success(let data):
                // 수정된 텍스트 delegate로 전달
                self.isFixing = false
                self.onChanged?(self.voiceDiaryFixView.textView.text)
                self.dismiss(animated: true, completion: nil)
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension VoiceDiaryFixViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let textLength = textView.text.count

        if textLength < 100 {
            // 100자 미만 → 무조건 비활성화
            voiceDiaryFixView.lessThanHundred(isEnabled: true)
            voiceDiaryFixView.fixButton.setButtonState(
                isEnabled: false,
                enabledColor: .primary400,
                disabledColor: .gray700,
                enabledTitleColor: .black,
                disabledTitleColor: .gray400
            )
        } else {
            // 100자 이상일 때 → 원래 텍스트와 달라야 활성화
            voiceDiaryFixView.lessThanHundred(isEnabled: false)
            let changedState = textView.text != self.text
            voiceDiaryFixView.fixButton.setButtonState(
                isEnabled: changedState,
                enabledColor: .primary400,
                disabledColor: .gray700,
                enabledTitleColor: .black,
                disabledTitleColor: .gray400
            )
        }
    }
}

