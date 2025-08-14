//
//  VoiceDiarySummaryViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/16/25.
//

import UIKit

class VoiceDiarySummaryViewController: UIViewController, VoiceDiaryErrorDelegate {
    
    // MARK: Properties
    let voiceDiarySummaryView = VoiceDiarySummaryView()
    let navigationBarManager = NavigationManager()
    let diaryContent: String
    let diaryId: Int
    let date: String
    
    private var recommendedChallenges: [RecommendedChallenge] = []
    private var emotionKeywords: [EmotionKeyword] = []
    
    let diaryService = DiaryService()
    
    init(diaryContent: String, diaryId: Int, date: String) {
        self.diaryContent = diaryContent
        self.diaryId = diaryId
        self.date = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.fetchDiaryAnalyze()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupActions()
        
        voiceDiarySummaryView.configure(text: diaryContent)
        voiceDiarySummaryView.updateDate(with: date)
    }
    
    // MARK: Setup Navigation Bar
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
        view.addSubview(voiceDiarySummaryView)
        voiceDiarySummaryView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: Setup Actions
    private func setupActions() {
        voiceDiarySummaryView.saveButton.addTarget(self, action: #selector(nextVC), for: .touchUpInside)
        
        let labelAction = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        voiceDiarySummaryView.descriptionLabel.addGestureRecognizer(labelAction)
    }
    
    //MARK: - @objc methods
    @objc func prevVC() {
        let prevVC = VoiceDiarySummaryErrorViewController()
        prevVC.delegate = self
        prevVC.diaryId = diaryId
        let navController = UINavigationController(rootViewController: prevVC)
        navController.modalPresentationStyle = .fullScreen
        presentPageSheet(viewController: navController, detentFraction: 0.37)
    }
    
    @objc func nextVC() {
        let nextVC = VoiceDiaryRecommendChallengeViewController()
        nextVC.diaryId = diaryId
        nextVC.recommendedChallenges = recommendedChallenges
        nextVC.emotionKeywords = emotionKeywords
        nextVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc func labelTapped() {
        let nextVC = VoiceDiaryFixViewController(text: diaryContent)
        nextVC.diaryId = diaryId
        nextVC.emotionKeywords = emotionKeywords
        nextVC.recommendedChallenges = recommendedChallenges
        let navController = UINavigationController(rootViewController: nextVC)
        navController.modalPresentationStyle = .fullScreen
        presentPageSheet(viewController: navController, detentFraction: 0.6)
    }
    
    func didTapExitButton() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: Setup APIs
    private func fetchDiaryAnalyze() {
        diaryService.postVoiceDiaryAnalyze(
            diaryId: diaryId,
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    print(data)
                    DispatchQueue.main.async {
                        self.voiceDiarySummaryView.updateEmo(emotionKeywords: data.emotionKeywords)
                        self.recommendedChallenges = data.recommendedChallenges
                        self.emotionKeywords = data.emotionKeywords
                    }
                case .failure(let error):
                    print(error)
                }
            })
    }
}
