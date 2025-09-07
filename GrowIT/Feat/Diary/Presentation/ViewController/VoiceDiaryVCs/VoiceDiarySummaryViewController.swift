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
    
    private var recommendedChallenges: [RecommendedDiaryChallengeDTO] = []
    private var emotionKeywords: [EmotionKeyword] = []
    
    let diaryService = DiaryService()
    
    init(diaryContent: String, diaryId: Int, date: String, keywords: [EmotionKeyword], recommendedChallenges: [RecommendedDiaryChallengeDTO]) {
        self.diaryContent = diaryContent
        self.diaryId = diaryId
        self.date = date
        self.emotionKeywords = keywords
        self.recommendedChallenges = recommendedChallenges
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupActions()
        
        
        voiceDiarySummaryView.configure(text: diaryContent)
        voiceDiarySummaryView.updateDate(with: date)
        voiceDiarySummaryView.updateEmo(emotionKeywords: emotionKeywords)
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
        presentSheet(navController, heightRatio: 0.37)
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
        presentSheet(navController, heightRatio: 0.6)
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
    
}
