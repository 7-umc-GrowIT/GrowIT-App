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
        
    var recommendedChallenges: [RecommendedDiaryChallengeDTO] = []
    var emotionKeywords: [EmotionKeyword] = []
    
    private var challengeViews: [VoiceChallengeItemView] {
        return voiceDiaryRecommendChallengeView.challengeStackView.challengeViews
    }
    
    var isSaving: Bool = false
    
    override func viewDidLoad() {
        navigationController?.navigationBar.isHidden = false
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupActions()
        
        self.voiceDiaryRecommendChallengeView.updateChallenges(self.recommendedChallenges)
        self.voiceDiaryRecommendChallengeView.updateEmo(emotionKeywords: self.emotionKeywords)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
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
            textColor: .gray900
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
        presentSheet(navController, heightRatio: 0.336)
    }
    
    @objc func nextVC() {
        let selectedChallenges = getSelectedChallenges()
        
        if selectedChallenges.isEmpty {
            CustomToast(containerWidth: 314).show(image: UIImage(named: "toastIcon") ?? UIImage(),
                       message: "한 개 이상의 챌린지를 선택해 주세요",
                       font: .heading3SemiBold())
            return
        }
        
        guard !isSaving else { return }
        isSaving = true
        challengeService.postSelectedChallenge(data: ChallengeSelectRequestDTO(diaryId: self.diaryId, challenges: selectedChallenges)) { [weak self] result in
            guard let self = self else { return }
            self.isSaving = false
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
        if let navigationController = self.navigationController {
            var viewControllers = navigationController.viewControllers
            // 루트 다음 뷰컨트롤러 인덱스는 1
            if viewControllers.count > 1 {
                let targetVC = viewControllers[1]
                navigationController.setViewControllers([viewControllers[0], targetVC], animated: true)
            }
        }
    }
    
    func getSelectedChallenges() -> [SelectedChallengeDTO] {
        // 선택된 챌린지들 필터링
        let selectedChallenges = challengeViews.enumerated()
            .filter { index, challengeView in
                index < recommendedChallenges.count && challengeView.button.isSelectedState()
            }
            .map { index, _ in
                recommendedChallenges[index]
            }
        
        // 챌린지 타입별로 그룹핑
        let groupedChallenges = Dictionary(grouping: selectedChallenges) { challenge in
            challenge.challengeType
        }
        
        // 각 그룹을 DTO로 변환
        return groupedChallenges.map { (challengeType, challenges) in
            let challengeIds = challenges.map { $0.id }
            return SelectedChallengeDTO(
                challengeIds: challengeIds,
                challengeType: challengeType
            )
        }
    }
}
