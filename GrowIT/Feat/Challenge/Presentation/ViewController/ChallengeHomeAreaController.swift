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
    private let pageControl = UIPageControl()
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
                    self.challengeHomeArea.setEmptyChallenge(true)
                    self.pageControl.isHidden = true
                } else {
                    self.challengeHomeArea.setEmptyChallenge(false)
                    self.pageControl.isHidden = false
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
        pageControl.numberOfPages = todayChallenges.count
        pageControl.currentPage = selectedIndex
        pageControl.currentPageIndicatorTintColor = .primary600
        pageControl.pageIndicatorTintColor = .gray
        
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints {
            $0.top.equalTo(challengeHomeArea.todayChallengeCollectionView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        
        challengeHomeArea.challengeReportTitleStack.snp.remakeConstraints {
            $0.top.equalTo(pageControl.snp.bottom).offset(44)
            $0.left.equalToSuperview().offset(24)
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateChallengeList), name: .challengeReloadNotification, object: nil)
    }
    
    @objc private func updateChallengeList() {
        viewModel.refresh()
    }
    
    public func refreshData(){
        viewModel.refresh()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDelegate, DataSource
extension ChallengeHomeAreaController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
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
        let challenge = todayChallenges[indexPath.row]
        let availableWidth = collectionView.frame.width * 0.5
        let size = CGSize(width: availableWidth, height: .greatestFiniteMagnitude)
        let attributes = [NSAttributedString.Key.font: UIFont.heading3Bold()]
        let estimatedFrame = NSString(string: challenge.title).boundingRect(
            with: size,
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        )
        
        let lines = ceil(estimatedFrame.height / UIFont.heading3Bold().lineHeight)
        let cellHeight = 78 + (lines * UIFont.heading3Bold().lineHeight)
        
        challengeHomeArea.todayChallengeCollectionView.snp.updateConstraints {
            $0.height.equalTo(cellHeight)
        }
        
        view.layoutIfNeeded()
        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        let challenge = todayChallenges[indexPath.row]
        
        if challenge.completed {
            let completeVC = ChallengeCompleteViewController()
            presentSheet(completeVC, heightRatio: 1.0, useLargeOnly: true)
        } else {
            let verifyModalVC = ChallengeVerifyModalController()
            verifyModalVC.challengeId = challenge.id
            presentSheet(verifyModalVC, heightRatio: 0.34)
        }
    }
}

// MARK: - ScrollView Delegate
extension ChallengeHomeAreaController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visiblePoint = CGPoint(x: scrollView.contentOffset.x + scrollView.bounds.width / 2, y: scrollView.bounds.height / 2)
        if let indexPath = challengeHomeArea.todayChallengeCollectionView.indexPathForItem(at: visiblePoint) {
            selectedIndex = indexPath.row
            pageControl.currentPage = indexPath.row
        }
    }
}
