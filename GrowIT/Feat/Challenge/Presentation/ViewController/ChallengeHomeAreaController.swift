//
//  ChallengeHomeAreaController.swift
//  GrowIT
//
//  Created by 허준호 on 1/22/25.
//

import UIKit
import SnapKit
import Then
import Combine

class ChallengeHomeAreaController: UIViewController {
    private let challengeHomeArea = ChallengeHomeArea()
    private var todayChallenges: [RecommendedChallengeDTO] = []
    private var selectedIndex = 0
    
    private var viewModel: ChallengeHomeViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: ChallengeHomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = challengeHomeArea
        view.backgroundColor = .gray50
        
        setupCollectionView()
        setupNotifications()
        bindViewModel()
        viewModel.refresh()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewHeight(for: selectedIndex)
    }

    func updateCollectionViewHeight(for index: Int) {
        guard todayChallenges.count > index else { return }
        let challenge = todayChallenges[index]
        let label = UILabel()
        label.font = .heading3Bold()
        label.numberOfLines = 0
        label.text = challenge.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let availableWidth = UIScreen.main.bounds.width * 0.88 * 0.45
        let size = label.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude))
        let baseHeight: CGFloat = 78
        let targetHeight = max(100, size.height + baseHeight)
        challengeHomeArea.todayChallengeCollectionView.snp.updateConstraints { $0.height.equalTo(targetHeight) }
        view.layoutIfNeeded()
    }
    
    private func setupCollectionView() {
        challengeHomeArea.todayChallengeCollectionView.delegate = self
        challengeHomeArea.todayChallengeCollectionView.dataSource = self
    }
    
    private func bindViewModel() {
        viewModel.$todayChallenges
            .receive(on: RunLoop.main)
            .sink { [weak self] challenges in
                guard let self = self else { return }
                self.todayChallenges = challenges
                self.challengeHomeArea.todayChallengeCollectionView.reloadData()
                self.setupPageControl()
                
                // 빈 챌린지 상태 처리
                let isEmpty = challenges.isEmpty
                if isEmpty {
                    if viewModel.keywords.isEmpty {
                        self.challengeHomeArea.setEmptyChallenge(isEmptyChallenge: true, isEmptyKeyword: true)
                        self.challengeHomeArea.pageControl.isHidden = true
                    }else {
                        self.challengeHomeArea.setEmptyChallenge(isEmptyChallenge: true, isEmptyKeyword: false)
                        self.challengeHomeArea.pageControl.isHidden = true
                    }
                } else {
                    self.challengeHomeArea.setEmptyChallenge(isEmptyChallenge: false, isEmptyKeyword: false)
                    self.challengeHomeArea.pageControl.isHidden = false
                }
            }
            .store(in: &cancellables)
        
        viewModel.$keywords
            .sink { [weak self] in self?.challengeHomeArea.setupChallengeKeywords($0) }
            .store(in: &cancellables)
        
        viewModel.$report
            .sink { [weak self] in
                guard let report = $0 else { return }
                self?.challengeHomeArea.setupChallengeReport(report: report)
            }
            .store(in: &cancellables)
    }
    
    private func setupPageControl() {
        challengeHomeArea.pageControl.numberOfPages = todayChallenges.count
        challengeHomeArea.pageControl.currentPage = selectedIndex
        challengeHomeArea.pageControl.currentPageIndicatorTintColor = .primary600
        challengeHomeArea.pageControl.pageIndicatorTintColor = .gray
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToVerify), name: NSNotification.Name("navigateToChallengeVerify"), object: nil)
    }
    
    @objc private func navigateToVerify() {
        guard !view.isHidden else { return }
        let challengeVerifyVC = ChallengeVerifyViewController(challenge: UserChallenge(dto: todayChallenges[selectedIndex]))
        navigationController?.pushViewController(challengeVerifyVC, animated: true)
    
    }
    
    public func refreshData(){
        viewModel.refresh()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDelegate, DataSource
extension ChallengeHomeAreaController: UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todayChallenges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TodayChallengeCollectionViewCell.identifier,
            for: indexPath
        ) as? TodayChallengeCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let challenge = todayChallenges[indexPath.row]
        cell.figure(title: challenge.title, time: challenge.time, completed: challenge.completed)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let challenge = viewModel.todayChallenges[indexPath.row]
        
        let label = UILabel()
        label.font = .heading3Bold()
        label.numberOfLines = 0
        label.text = challenge.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let availableWidth = collectionView.frame.width * 0.45 // name label 제약과 동일
        let size = label.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude))
        
        let titleHeight = size.height
        let baseHeight: CGFloat = 78 // top + spacing + bottom inset
        print("셀 높이는 \(titleHeight + baseHeight)")
        return CGSize(width: collectionView.frame.width, height: max(100, titleHeight + baseHeight))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        let challenge = todayChallenges[indexPath.row]
        
        if challenge.completed {
            let completeVC = ChallengeCompleteViewController()
            completeVC.challengeId = challenge.id
            presentSheet(completeVC, heightRatio: 1.0, useLargeOnly: true)
        } else {
            let verifyModalVC = ChallengeVerifyModalController()
            verifyModalVC.challengeId = challenge.id
            presentSheet(verifyModalVC, heightRatio: 0.4)
        }
    }
}

// MARK: - ScrollView Delegate
extension ChallengeHomeAreaController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visiblePoint = CGPoint(
            x: scrollView.contentOffset.x + scrollView.bounds.width / 2,
            y: scrollView.bounds.height / 2
        )
        guard let indexPath = challengeHomeArea.todayChallengeCollectionView.indexPathForItem(at: visiblePoint) else { return }
        selectedIndex = indexPath.row
        challengeHomeArea.pageControl.currentPage = selectedIndex
        
        // ---------- 동적 Height 계산 ----------
        let challenge = todayChallenges[selectedIndex]
        let label = UILabel()
        label.font = .heading3Bold()
        label.numberOfLines = 0
        label.text = challenge.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let availableWidth = scrollView.frame.width * 0.45 // 또는 셀과 동일한 width
        let size = label.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude))
        let baseHeight: CGFloat = 78 // 패딩·여백 포함
        let newHeight = max(100, size.height + baseHeight)
        
        UIView.animate(withDuration: 0.1) {
            self.challengeHomeArea.todayChallengeCollectionView.snp.updateConstraints {
                $0.height.equalTo(newHeight)
            }
            self.view.layoutIfNeeded()
        }
    }

}
