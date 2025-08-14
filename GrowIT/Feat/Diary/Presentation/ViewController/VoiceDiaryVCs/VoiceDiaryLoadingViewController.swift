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
    
    private var diaryContent: String?
    
    weak var delegate: VoiceDiaryRecordDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
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

    func navigateToNextScreen(with content: String, diaryId: Int, date: String) {
        self.diaryContent = content
        
        let nextVC = VoiceDiarySummaryViewController(diaryContent: diaryContent ?? "", diaryId: diaryId, date: date)
        nextVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(nextVC, animated: true)
    }
}
