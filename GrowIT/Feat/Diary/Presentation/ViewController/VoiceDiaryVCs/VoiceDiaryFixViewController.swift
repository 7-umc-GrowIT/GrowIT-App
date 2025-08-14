//
//  VoiceDiaryFixViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/16/25.
//

import UIKit

class VoiceDiaryFixViewController: UIViewController {
    
    // MARK: Properties
    let text: String
    let voiceDiaryFixView = VoiceDiaryFixView()
    
    var diaryId = 0
    let diaryService = DiaryService()
    
    var recommendedChallenges: [RecommendedChallenge] = []
    var emotionKeywords: [EmotionKeyword] = []
    
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
        if let presentingVC = presentingViewController as? UINavigationController {
            dismiss(animated: true) {
                let nextVC = VoiceDiaryRecommendChallengeViewController()
                nextVC.diaryId = self.diaryId
                nextVC.recommendedChallenges = self.recommendedChallenges
                nextVC.emotionKeywords = self.emotionKeywords
                presentingVC.pushViewController(nextVC, animated: true)
            }
        }
    }
}

extension VoiceDiaryFixViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let textLength = textView.text.count
        if textLength < 100 {
            voiceDiaryFixView.lessThanHundred(isEnabled: true)
            voiceDiaryFixView.fixButton.setButtonState(isEnabled: false, enabledColor: .primary400, disabledColor: .gray700, enabledTitleColor: .black, disabledTitleColor: .gray400)
        } else {
            voiceDiaryFixView.lessThanHundred(isEnabled: false)
            let changedState = textView.text == self.text ? false : true
            voiceDiaryFixView.fixButton.setButtonState(
                isEnabled: changedState,
                enabledColor: .primary400,
                disabledColor: .gray700,
                enabledTitleColor: .black,
                disabledTitleColor: .gray400)
        }
    }
}
