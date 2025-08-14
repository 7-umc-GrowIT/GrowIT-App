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
        let nextVC = TextDiaryRecommendChallengeViewController(diaryId: diaryId)
        nextVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    //MARK: - @objc methods
}
