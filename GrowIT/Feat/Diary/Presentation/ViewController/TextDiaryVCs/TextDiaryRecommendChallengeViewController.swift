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
    
    private var recommendedChallenges: [RecommendedDiaryChallengeDTO] = []
    private var emotionKeywords: [EmotionKeyword] = []
    
    private var buttonCount: Int = 0
    let diaryId: Int
    let data: DiaryAnalyzeResponseDTO
    
    let diaryService = DiaryService()
    let challengeService = ChallengeService()
    
    private var challengeViews: [ChallengeItemView] {
        return textDiaryRecommendChallengeView.challengeStackView.challengeViews
    }
    
    var isSaving: Bool = false
    
    init(diaryId: Int, data: DiaryAnalyzeResponseDTO) {
        self.diaryId = diaryId
        self.data = data
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
        initialize()
    }
    
    private func initialize() {
        self.textDiaryRecommendChallengeView.updateEmo(emotionKeywords: data.emotionKeywords)
        self.recommendedChallenges = data.recommendedChallenges
        self.emotionKeywords = data.emotionKeywords
        self.textDiaryRecommendChallengeView.updateChallenges(self.recommendedChallenges)
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
            textColor: .gray900
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
        //let navController = UINavigationController(rootViewController: prevVC)
        presentSheet(prevVC, heightRatio: 314/932, fixedHeight: 314)
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
        challengeService.postSelectedChallenge(data: ChallengeSelectRequestDTO(
            diaryId: self.diaryId, challenges: selectedChallenges
        )) { [weak self] result in
            guard let self = self else { return }
            self.isSaving = false
            switch result {
            case .success(let response):
                print("챌린지 선택 성공: \(response)")
                let nextVC = TextDiaryEndViewController()
                nextVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(nextVC, animated: true)
            case .failure(let error):
                print("선택한 챌린지 저장 실패: \(error)")
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
        let tabBarController = CustomTabBarController(initialIndex: 0)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        window.rootViewController = UINavigationController(rootViewController: tabBarController)
        window.makeKeyAndVisible()
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
