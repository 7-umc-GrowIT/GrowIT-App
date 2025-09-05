//
//  VoiceDiaryLoadingViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/16/25.
//

import UIKit

class VoiceDiaryLoadingViewController: UIViewController {

    //MARK: - Properties
    let voiceDiaryLoadingView = VoiceDiaryLoadingView()
    let navigationBarManager = NavigationManager()
    let diaryService = DiaryService()
    
    private let diary: Diary
    
    weak var delegate: VoiceDiaryRecordDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        
        fetchDiaryAnalyze() { result in
            let nextVC = VoiceDiarySummaryViewController(diaryContent: self.diary.content, diaryId: self.diary.id, date: self.diary.date, keywords: result.emotionKeywords, recommendedChallenges: result.recommendedChallenges)
            nextVC.hidesBottomBarWhenPushed = true
            
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    init(diary: Diary) {
        self.diary = diary
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup Navigation Bar
    private func setupNavigationBar() {
        navigationBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(prevVC),
            tintColor: .clear
        )
        
        navigationBarManager.setTitle(
            to: navigationItem,
            title: "",
            textColor: .black
        )
    }

    //MARK: - Setup UI
    private func setupUI() {
        view.addSubview(voiceDiaryLoadingView)
        voiceDiaryLoadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    //MARK: - @objc methods
    @objc func prevVC() {
        // navigationController?.popViewController(animated: true)
    }
    
    private func fetchDiaryAnalyze(completion: @escaping (DiaryAnalyzeResponseDTO) -> Void) {
        diaryService.postVoiceDiaryAnalyze(diaryId: diary.id) { result in
            switch result {
            case .success(let data):
                print(data)
                completion(data)
            case .failure(let error):
                print(error)
            }
        }
    }
}
