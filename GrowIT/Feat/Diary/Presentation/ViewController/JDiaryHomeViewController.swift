//
//  JDiaryHomeViewController.swift
//  GrowIT
//
//  Created by 허준호 on 1/14/25.
//

import UIKit
import SnapKit

class JDiaryHomeViewController: UIViewController {
    
    private lazy var jDiaryHomeView = JDiaryHomeView()
    private lazy var jDiaryCalendarVC = JDiaryCalendarController(isDropDown: false)
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = jDiaryHomeView
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        setupCalendarView()
        setupActions()
    }
    
    @objc private func diaryDirectWriteButtonTapped() {
        let textDiaryVC = TextDiaryViewController()
        
        navigationController?.pushViewController(textDiaryVC, animated: false)
    }
    
    private func setupCalendarView() {
        // 캘린더 뷰 컨트롤러를 자식으로 추가
        addChild(jDiaryCalendarVC)
        jDiaryCalendarVC.didMove(toParent: self)
        jDiaryCalendarVC.configureTheme(isDarkMode: false)
        
        // 캘린더 뷰를 JDiaryHomeView에 추가
        jDiaryHomeView.diaryHomeStack.addArrangedSubview(jDiaryCalendarVC.view)
        setupCalendarViewConstraints()
    }
    
    private func setupCalendarViewConstraints() {
        jDiaryCalendarVC.view.snp.makeConstraints{
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setupActions() {
        // Diary 뷰 관련 액션
        let voiceAction = UITapGestureRecognizer(target: self, action: #selector(voiceVC))
        let textAction = UITapGestureRecognizer(target: self, action: #selector(textVC))
        
        jDiaryHomeView.diaryHomeBanner.diaryDirectWriteButton.addGestureRecognizer(textAction)
        jDiaryHomeView.diaryHomeBanner.diaryWriteButton.addGestureRecognizer(voiceAction)
        jDiaryHomeView.diaryHomeCalendarHeader.collectBtn.addTarget(self, action: #selector(diaryAllVC), for: .touchUpInside)
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
}


