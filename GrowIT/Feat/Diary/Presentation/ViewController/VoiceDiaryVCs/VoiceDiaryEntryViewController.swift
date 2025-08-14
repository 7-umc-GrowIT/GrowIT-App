//
//  VoiceDiaryEntryViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/16/25.
//

import UIKit

class VoiceDiaryEntryViewController: UIViewController {
    
    // MARK: Properties
    let navigationBarManager = NavigationManager()
    
    let voiceDiaryEntryView = VoiceDiaryEntryView()
    
    let diaryService = DiaryService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupActions()
        navigationController?.navigationBar.isHidden = false
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
        view.addSubview(voiceDiaryEntryView)
        voiceDiaryEntryView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: Setup Actions
    private func setupActions() {
        voiceDiaryEntryView.recordButton.addTarget(self, action: #selector(nextVC), for: .touchUpInside)
        
        let labelAction = UITapGestureRecognizer(target: self, action: #selector(labeledTapped))
        voiceDiaryEntryView.helpLabel.addGestureRecognizer(labelAction)
    }
    
    //MARK: - @objc methods
    @objc func prevVC() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func nextVC() {
        // callPostTextDiary()
        let nextVC = VoiceDiaryDateSelectViewController()
        nextVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc func labeledTapped() {
        let nextVC = VoiceDiaryTipViewController()
        nextVC.modalPresentationStyle = .pageSheet
        
        if let sheet = nextVC.sheetPresentationController {
            //지원할 크기 지정
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .custom{ context in
                        0.37 * context.maximumDetentValue
                    }
                ]
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true
        }
        present(nextVC, animated: true, completion: nil)
    }
}
