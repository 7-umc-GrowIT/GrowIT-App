//
//  VoiceDiaryDateSelectViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/16/25.
//

import UIKit

class VoiceDiaryDateSelectViewController: UIViewController, DiaryCalendarControllerDelegate {
    // MARK: Properties
    let  voiceDiaryDateSelectView = VoiceDiaryDateSelectView()
    let navigationBarManager = NavigationManager()
    
    let calVC = DiaryCalendarController(isDropDown: true)
    
    var isCalendarOpen: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        setupUI()
        setupNavigationBar()
        setupActions()
        setupDelegate()
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
            textColor: .gray900
        )
    }
    
    // MARK: Setup UI
    private func setupUI() {
        view.addSubview(voiceDiaryDateSelectView)
        voiceDiaryDateSelectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(calVC.view)
        addChild(calVC)
        calVC.configureTheme(isDarkMode: true)
        calVC.didMove(toParent: self)
        calVC.view.snp.makeConstraints { make in
            make.top.equalTo(voiceDiaryDateSelectView.dateView.snp.bottom).offset(8)
            make.leading.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(Constants.Screen.ScreenHeight * (Constants.Screen.CalenderRatio))
        }
        calVC.view.isHidden = true
    }
    
    private func updateDateSelectionUI(isValid: Bool) {
        let v = voiceDiaryDateSelectView
        if isValid {
            v.dateLabel.textColor = .gray300
            v.dateView.layer.borderColor = UIColor.clear.cgColor
            v.toggleButton.tintColor = .gray500
            v.dateSelectLabel.textColor = .white
            v.warningLabel.isHidden = true
        } else {
            v.dateLabel.textColor = .negative400W
            v.dateView.layer.borderColor = UIColor.negative100.cgColor
            v.toggleButton.tintColor = .negative400W
            v.dateSelectLabel.textColor = .negative400W
            v.warningLabel.isHidden = false
        }
        
        
    }
    
    // MARK: Setup Delegate
    private func setupDelegate() {
        calVC.delegate = self
    }
    
    // MARK: Setup Actions
    private func setupActions() {
        voiceDiaryDateSelectView.startButton.addTarget(self, action: #selector(nextVC), for: .touchUpInside)
        
        voiceDiaryDateSelectView.helpLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(labelTapped)))
        
        voiceDiaryDateSelectView.dateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleTapped)))
    }
    
    
    // MARK: @objc methods
    @objc func prevVC() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func nextVC() {
        if voiceDiaryDateSelectView.dateSelectLabel.text == "일기 날짜를 선택해 주세요" {
            updateDateSelectionUI(isValid: false)
        } else {
            let nextVC = VoiceDiaryRecordViewController(
                speechToTextUseCase: SpeechToTextUseCase(
                    googleSpeechRepository: GoogleSpeechRepositoryImpl(
                        dataSource: GoogleSpeechDataSourceImpl()
                    )
                ),
                getSTTResponseUseCase: GetSTTResponseUseCase(
                    diaryVoiceRepository: DiaryVoiceRepositoryImpl(
                        dataSource: DiaryVoiceDataSourceImpl(
                            diaryService: DiaryService()
                        )
                    )
                ),
                textToSpeechUseCase: TextToSpeechUseCase(
                    googleSpeechRepository: GoogleSpeechRepositoryImpl(
                        dataSource: GoogleSpeechDataSourceImpl()
                    )
                ),
                postVoiceDiaryUseCase: PostVoiceDiaryDateUseCase(
                    repository: DiaryVoiceRepositoryImpl(
                        dataSource: DiaryVoiceDataSourceImpl(
                            diaryService: DiaryService()
                        )
                    )
                )
            )
            nextVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(nextVC, animated: true)
        }
        
    }
    
    @objc func labelTapped() {
        let nextVC = VoiceDiaryTipViewController()
        nextVC.modalPresentationStyle = .pageSheet
        
        presentSheet(nextVC, heightRatio: 0.7)
    }
    
    @objc func toggleTapped() {
        isCalendarOpen.toggle()
        
        // 현재 날짜 선택 상태가 유효한지 확인
        var isValid = voiceDiaryDateSelectView.dateSelectLabel.textColor != .negative400W
        
        if (isCalendarOpen && !isValid) {
            updateDateSelectionUI(isValid: true)
            isValid = true
        }
        
        // 유효할 때만 초록색 테두리 적용
        voiceDiaryDateSelectView.dateView.layer.borderColor = (isCalendarOpen && isValid) ? UIColor.primary500.cgColor : UIColor.clear.cgColor
        
        calVC.view.isHidden.toggle()
    }
    
    func didSelectDate(_ date: String) {
        voiceDiaryDateSelectView.updateDateLabel(date)
        UserDefaults.standard.set(date, forKey: "VoiceDate")
        isCalendarOpen = false
        calVC.view.isHidden = true
        
        updateDateSelectionUI(isValid: true)
    }
    
    func diaryCalendar(_ controller: DiaryCalendarController, didChangeWeekCount count: Int, _ cellWidth: Double) {
        let extraHeight: CGFloat = 88       // 기존에 더한 높이
        let totalHeight = CGFloat(count) * cellWidth + extraHeight

        calVC.view.snp.updateConstraints { make in
            make.height.equalTo(totalHeight)
        }

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

}
