//
//  JDiaryHomeViewController.swift
//  GrowIT
//
//  Created by 허준호 on 1/14/25.
//

import UIKit
import SnapKit

class DiaryHomeViewController: UIViewController {
    
    private lazy var diaryHomeView = DiaryHomeView()
    private lazy var diaryCalendarVC = DiaryCalendarController(isDropDown: false)
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = diaryHomeView
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        setupCalendarView()
        setupActions()
        
        diaryHomeView.diaryHomeNavbar.settingBtn.addTarget(self, action: #selector(goToMyPage), for: .touchUpInside)
    }
    
    @objc private func diaryDirectWriteButtonTapped() {
        let textDiaryVC = TextDiaryViewController()
        
        navigationController?.pushViewController(textDiaryVC, animated: false)
    }
    
    private func setupCalendarView() {
        // 캘린더 뷰 컨트롤러를 자식으로 추가
        addChild(diaryCalendarVC)
        diaryCalendarVC.didMove(toParent: self)
        diaryCalendarVC.configureTheme(isDarkMode: false)
        
        // 캘린더 뷰를 DiaryHomeView에 추가
        diaryHomeView.contentView.addSubview(diaryCalendarVC.view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 캘린더 제약설정
        diaryCalendarVC.view.snp.makeConstraints {
            $0.top.equalTo(diaryHomeView.diaryHomeCalendarHeader.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            let bottomInset = self.view.bounds.height * 0.16
            $0.bottom.equalToSuperview().inset(bottomInset)
        }
    }
    
    private func setupActions() {
        // Diary 뷰 관련 액션
        let voiceAction = UITapGestureRecognizer(target: self, action: #selector(voiceVC))
        let textAction = UITapGestureRecognizer(target: self, action: #selector(textVC))
        
        diaryHomeView.diaryHomeBanner.diaryDirectWriteButton.addGestureRecognizer(textAction)
        diaryHomeView.diaryHomeBanner.diaryWriteButton.addGestureRecognizer(voiceAction)
        diaryHomeView.diaryHomeCalendarHeader.allViewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(diaryAllVC)))
    }
    
    // MARK: Diary View
    @objc func textVC() {
        let nextVC = TextDiaryViewController()
        nextVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc func voiceVC() {
        let nextVC = VoiceDiaryEntryViewController()
        nextVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc func diaryAllVC() {
        let nextVC = DiaryAllViewController()
        nextVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc private func goToMyPage() {
        let myPageVC = MypageViewController()
        navigationController?.pushViewController(myPageVC, animated: true)
    }
}


