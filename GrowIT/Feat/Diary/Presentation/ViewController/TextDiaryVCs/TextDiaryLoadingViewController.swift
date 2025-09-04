//
//  TextDiaryLoadingViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/12/25.
//

import UIKit

class TextDiaryLoadingViewController: UIViewController {
    
    //MARK: - Properties
    let textDiaryLoadingView = TextDiaryLoadingView()
    let diaryService = DiaryService()
    private let diaryId: Int
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        setupUI()
        
        fetchDiaryAnalyze(diaryId: diaryId) { result in
            let nextVC = TextDiaryRecommendChallengeViewController(diaryId: self.diaryId, data: result)
            nextVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    init(diaryId: Int) {
        self.diaryId = diaryId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(textDiaryLoadingView)
        textDiaryLoadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func navigateToNextScreen(with diaryId: Int) {
        fetchDiaryAnalyze(diaryId: diaryId) { data in
            
        }
    }
    
    private func fetchDiaryAnalyze(diaryId: Int, completion: @escaping (DiaryAnalyzeResponseDTO) -> Void) {
        diaryService.postVoiceDiaryAnalyze(
            diaryId: diaryId,
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    print(data)
                    completion(data)
                case .failure(let error):
                    print(error)
                }
            })
    }
}
