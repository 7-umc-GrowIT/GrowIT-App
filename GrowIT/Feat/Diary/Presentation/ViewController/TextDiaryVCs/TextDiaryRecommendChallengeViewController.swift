//
//  TextDiaryRecommendChallengeViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/12/25.
//

import UIKit

class TextDiaryRecommendChallengeViewController: UIViewController, VoiceDiaryErrorDelegate {
    
    //MARK: - Properties
    let textDiaryRecommendChallengeView = TextDiaryRecommendChallengeView()
    let navigationBarManager = NavigationManager()
    
    private var recommendedChallenges: [RecommendedChallenge] = []
    private var emotionKeywords: [EmotionKeyword] = []
    
    private var buttonCount: Int = 0
    let diaryId: Int
    
    let diaryService = DiaryService()
    let challengeService = ChallengeService()
    
    private var challengeViews: [ChallengeItemView] {
        return textDiaryRecommendChallengeView.challengeStackView.challengeViews
    }
    
    init(diaryId: Int) {
        self.diaryId = diaryId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        setupUI()
        setupNavigationBar()
        setupActions()
        fetchDiaryAnalyze(diaryId: diaryId)
    }
    
    //MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        navigationBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(prevVC),
            tintColor: .black
        )
        
        navigationBarManager.setTitle(
            to: navigationItem,
            title: "직접 일기 작성하기",
            textColor: .black
        )
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(textDiaryRecommendChallengeView)
        textDiaryRecommendChallengeView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    //MARK: - Setup Actions
    private func setupActions() {
        challengeViews.forEach { challengeView in
            challengeView.button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
        textDiaryRecommendChallengeView.saveButton.addTarget(self, action: #selector(nextVC), for: .touchUpInside)
    }
    
    //MARK: - @objc methods
    @objc func prevVC() {
        let prevVC = TextDiaryErrorViewController()
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
                let nextVC = TextDiaryEndViewController()
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
        
        textDiaryRecommendChallengeView.saveButton.setButtonState(
            isEnabled: buttonState,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
    }
    
    func didTapExitButton() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: API func
    private func fetchDiaryAnalyze(diaryId: Int) {
        diaryService.postVoiceDiaryAnalyze(
            diaryId: diaryId,
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    print(data)
                    DispatchQueue.main.async {
                        self.textDiaryRecommendChallengeView.updateEmo(emotionKeywords: data.emotionKeywords)
                        self.recommendedChallenges = data.recommendedChallenges
                        self.emotionKeywords = data.emotionKeywords
                        self.textDiaryRecommendChallengeView.updateChallenges(self.recommendedChallenges)
                    }
                case .failure(let error):
                    print(error)
                }
            })
    }
    
    func getSelectedChallenges() -> [ChallengeSelectRequestDTO] {
        let date = UserDefaults.standard.string(forKey: "TextDate") ?? ""
        return challengeViews.enumerated().compactMap { index, challengeView in
            guard index < recommendedChallenges.count, challengeView.button.isSelectedState() else { return nil }
            let challenge = recommendedChallenges[index]
            return ChallengeSelectRequestDTO(challengeIds: [challenge.id], dtype: challenge.type, date: date)
        }
    }
}
