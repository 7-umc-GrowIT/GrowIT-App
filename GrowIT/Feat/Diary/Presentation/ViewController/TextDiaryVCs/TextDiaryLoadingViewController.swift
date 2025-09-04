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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        setupUI()
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
            let nextVC = TextDiaryRecommendChallengeViewController(diaryId: diaryId, data: data)
            nextVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(nextVC, animated: true)
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
    
    //MARK: - @objc methods
}
