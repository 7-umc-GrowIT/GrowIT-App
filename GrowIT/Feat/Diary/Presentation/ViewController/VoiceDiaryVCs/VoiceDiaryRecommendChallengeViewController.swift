//
//  VoiceDiaryRecommendChallengeViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/16/25.
//

import UIKit

class VoiceDiaryRecommendChallengeViewController: UIViewController, VoiceDiaryErrorDelegate {
    
    // MARK: Properties
    let voiceDiaryRecommendChallengeView = VoiceDiaryRecommendChallengeView()
    let navigationBarManager = NavigationManager()
    private let diaryService = DiaryService()
    private let challengeService = ChallengeService()
    
    private var buttonCount: Int = 0
    
    var diaryId = 0
        
    var recommendedChallenges: [RecommendedChallenge] = []
    var emotionKeywords: [EmotionKeyword] = []
    
    private var challengeViews: [VoiceChallengeItemView] {
        return voiceDiaryRecommendChallengeView.challengeStackView.challengeViews
    }
    
    override func viewDidLoad() {
        navigationController?.navigationBar.isHidden = false
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupActions()
        
        voiceDiaryRecommendChallengeView.updateChallenges(recommendedChallenges)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        DispatchQueue.main.async {
            self.voiceDiaryRecommendChallengeView.updateEmo(emotionKeywords: self.emotionKeywords)
        }
    }
    
    //MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        navigationBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(prevVC),
            tintColor: .white
        )
        
        navigationBarManager.setTitle(
            to: navigationItem,
            title: "",
            textColor: .black
        )
    }
    
    // MARK: Setup UI
    private func setupUI() {
        view.addSubview(voiceDiaryRecommendChallengeView)
        voiceDiaryRecommendChallengeView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    //MARK: - Setup Actions
    private func setupActions() {
        challengeViews.forEach { challengeView in
            challengeView.button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
        
        voiceDiaryRecommendChallengeView.saveButton.addTarget(self, action: #selector(nextVC), for: .touchUpInside)
    }
    
    //MARK: - @objc methods
    @objc func prevVC() {
        let prevVC = VoiceDiaryRecommendErrorViewController()
        prevVC.delegate = self
        prevVC.diaryId = diaryId
        let navController = UINavigationController(rootViewController: prevVC)
        navController.modalPresentationStyle = .fullScreen
        presentPageSheet(viewController: navController, detentFraction: 0.37)
    }
    
    @objc func nextVC() {
        let selectedChallenges = getSelectedChallenges()
        
        if selectedChallenges.isEmpty {
            CustomToast(containerWidth: 314).show(image: UIImage(named: "toast_Icon") ?? UIImage(),
                       message: "한 개 이상의 챌린지를 선택해 주세요",
                       font: .heading3SemiBold())
            return
        }
        
        challengeService.postSelectedChallenge(data: selectedChallenges) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                print("챌린지 선택 성공: \(response)")
                let nextVC = VoiceDiaryEndViewController()
                nextVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(nextVC, animated: true)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    @objc func buttonTapped(_ sender: CircleCheckButton) {
        if sender.isSelectedState() {
            buttonCount += 1
        } else {
            buttonCount -= 1
        }
        let buttonState = buttonCount > 0
        
        voiceDiaryRecommendChallengeView.saveButton.setButtonState(
            isEnabled: buttonState,
            enabledColor: .primary400,
            disabledColor: .gray700,
            enabledTitleColor: .black,
            disabledTitleColor: .gray400
        )
    }
    
    func didTapExitButton() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: Setup APIs
    private func callPostVoiceDiary() {
        diaryService.postVoiceDiary(data: DiaryVoiceRequestDTO(
            chat: ""),
                                    completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success(let data):
                print("Success!!!!!!! \(data)")
            case.failure(let error):
                print("Error: \(error)")
            }
        })
    }
    
    func getSelectedChallenges() -> [ChallengeSelectRequestDTO] {
        let date = UserDefaults.standard.string(forKey: "VoiceDate") ?? ""
        return challengeViews.enumerated().compactMap { index, challengeView in
            guard index < recommendedChallenges.count, challengeView.button.isSelectedState() else { return nil }
            let challenge = recommendedChallenges[index]
            return ChallengeSelectRequestDTO(challengeIds: [challenge.id], dtype: challenge.type, date: date)
        }
    }
}
