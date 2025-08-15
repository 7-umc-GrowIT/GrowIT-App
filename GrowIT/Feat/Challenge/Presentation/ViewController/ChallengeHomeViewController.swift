//
//  ChallengHomeViewController.swift
//  GrowIT
//
//  Created by 허준호 on 1/21/25.
//

import UIKit
import SnapKit

class ChallengeHomeViewController: UIViewController {
    
    private lazy var challengeHomeView = ChallengeHomeView()
    private lazy var challengeHomeAreaVC = ChallengeHomeAreaController(
        viewModel: ChallengeHomeViewModel(
            useCase: GetChallengeHomeUseCaseImpl(
                repository: ChallengeRepositoryImpl(
                    dataSource: ChallengeDataSourceImpl()
                )
            )
        )
    )
    
    private lazy var challengeStatusAreaVC = ChallengeStatusAreaController(
        viewModel: ChallengeStatusViewModel(
            getChallengesUseCase: GetStatusChallengesUseCase(
                repository: ChallengeRepositoryImpl(
                    dataSource: ChallengeDataSourceImpl()
                )
            )
        )
    )
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = challengeHomeView
        view.backgroundColor = .white
        
        setCustomSegment()
        setupChallengeHomeArea()
        setupChallengeStatusArea()
        setupNotifications()
        
        challengeStatusAreaVC.refreshData()
        challengeHomeAreaVC.refreshData()
        
        challengeHomeAreaVC.view.isHidden = false
        challengeStatusAreaVC.view.isHidden = true
    }
    
    private func setupChallengeHomeArea(){
        addChild(challengeHomeAreaVC)
        challengeHomeAreaVC.didMove(toParent: self)
        challengeHomeView.addSubview(challengeHomeAreaVC.view)
        challengeHomeAreaVC.view.snp.makeConstraints{
            $0.top.equalTo(challengeHomeView.challengeSegmentUnderline.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setupChallengeStatusArea(){
        addChild(challengeStatusAreaVC)
        challengeStatusAreaVC.didMove(toParent: self)
        challengeHomeView.addSubview(challengeStatusAreaVC.view)
        challengeStatusAreaVC.view.snp.makeConstraints{
            $0.top.equalTo(challengeHomeView.challengeSegmentUnderline.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setCustomSegment(){
        challengeHomeView.challengeHomeBtn.setTitleColor(.primary600, for: .normal)
        challengeHomeView.challengeHomeBtn.addTarget(self, action: #selector(challengeHomeBtnTapped), for: .touchUpInside)
        challengeHomeView.challengeStatusBtn.addTarget(self, action: #selector(challengeStatusBtnTapped), for: .touchUpInside)
        
        challengeHomeView.updateUnderlinePosition(button: challengeHomeView.challengeHomeBtn, animated: false)
    }
    
    private func setupNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(moveChallengeVerfiyVC(_:)), name: .closeModalAndMoveVC, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleChallengeStatusReload), name: .challengeStatusReload, object: nil)
        
    }
    
    @objc private func moveChallengeVerfiyVC(_ notification: Notification) {
        if let userInfo = notification.userInfo, let challenge = userInfo["challenge"] as? UserChallenge{
            let nextVC = ChallengeVerifyViewController()
            
            navigationController?.pushViewController(nextVC, animated: true)
        }
        
    }
    
    @objc private func handleChallengeStatusReload() {
        // 상태 영역이 현재 안보이는 상태여도 항상 최신 데이터 유지
        challengeStatusAreaVC.refreshData()
    }
    
    @objc private func challengeHomeBtnTapped(){
        challengeHomeView.updateUnderlinePosition(button: challengeHomeView.challengeHomeBtn, animated: true)
        challengeHomeView.challengeHomeBtn.setTitleColor(.primary600, for: .normal)
        challengeHomeView.challengeStatusBtn.setTitleColor(.gray300, for: .normal)
        
        challengeHomeAreaVC.view.isHidden = false
        challengeStatusAreaVC.view.isHidden = true
        
        challengeStatusAreaVC.refreshData()
    }
    
    @objc private func challengeStatusBtnTapped(){
        challengeHomeView.updateUnderlinePosition(button: challengeHomeView.challengeStatusBtn, animated: true)
        challengeHomeView.challengeHomeBtn.setTitleColor(.gray300, for: .normal)
        challengeHomeView.challengeStatusBtn.setTitleColor(.primary600, for: .normal)
        
        challengeHomeAreaVC.view.isHidden = true
        challengeStatusAreaVC.view.isHidden = false
        
        challengeHomeAreaVC.refreshData()
    }
}
