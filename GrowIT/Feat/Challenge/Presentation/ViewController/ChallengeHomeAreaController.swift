import UIKit
import SnapKit
import Then
import Combine

class ChallengeHomeAreaController: UIViewController {
    private let challengeHomeArea = ChallengeHomeArea()
    private var todayChallenges: [RecommendedChallengeDTO] = []
    private var selectedIndex = 0
    var isFirstAppearance: Bool = true
    
    private var viewModel: ChallengeHomeViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    // 셀 높이 캐시
    private var cellHeights: [Int: CGFloat] = [:]
    
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
        
        // 첫 진입 시에만 실행
        if isFirstAppearance && !todayChallenges.isEmpty {
            // 컬렉션뷰 레이아웃이 완료된 후 높이 업데이트
            DispatchQueue.main.async {
                self.updateCollectionViewHeightAfterCellLayout(for: self.selectedIndex, animated: false)
                self.isFirstAppearance = false
            }
        }
    }

    // 셀 높이 계산 메서드 (재사용 가능)
    private func calculateCellHeight(for challenge: RecommendedChallengeDTO, collectionViewWidth: CGFloat) -> CGFloat {
        let label = UILabel()
        label.font = .heading3Bold()
        label.numberOfLines = 0
        label.text = challenge.title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let availableWidth = collectionViewWidth * 0.45 // name label 제약과 동일
        let size = label.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude))
        
        let titleHeight = size.height
        let baseHeight: CGFloat = 78 // top + spacing + bottom inset
        
        return max(100, titleHeight + baseHeight)
    }

    // 컬렉션뷰 높이를 셀 높이에 맞게 업데이트 (레이아웃 완료 후 호출)
    private func updateCollectionViewHeightAfterCellLayout(for index: Int, animated: Bool = true) {
        guard todayChallenges.count > index else { return }
        
        let collectionView = challengeHomeArea.todayChallengeCollectionView
        
        // 컬렉션뷰의 실제 너비가 설정된 후에 계산
        guard collectionView.frame.width > 0 else {
            // 레이아웃이 아직 완료되지 않은 경우 다시 시도
            DispatchQueue.main.async {
                self.updateCollectionViewHeightAfterCellLayout(for: index, animated: animated)
            }
            return
        }
        
        let challenge = todayChallenges[index]
        let cellHeight = calculateCellHeight(for: challenge, collectionViewWidth: collectionView.frame.width)
        
        print("컬렉션뷰 높이 업데이트: \(cellHeight)")
        
        let update = {
            self.challengeHomeArea.todayChallengeCollectionView.snp.updateConstraints {
                $0.height.equalTo(cellHeight)
            }
            self.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: update)
        } else {
            update()
        }
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
                
                print("챌린지 데이터 업데이트: \(challenges.count)개")
                
                self.todayChallenges = challenges
                self.cellHeights.removeAll() // 캐시 초기화
                
                // 컬렉션뷰 리로드
                self.challengeHomeArea.todayChallengeCollectionView.reloadData()
                self.setupPageControl()
                
                // 빈 챌린지 상태 처리
                let isEmpty = challenges.isEmpty
                if isEmpty {
                    if self.viewModel.keywords.isEmpty {
                        self.challengeHomeArea.setEmptyChallenge(isEmptyChallenge: true, isEmptyKeyword: true)
                        self.challengeHomeArea.pageControl.isHidden = true
                    } else {
                        self.challengeHomeArea.setEmptyChallenge(isEmptyChallenge: true, isEmptyKeyword: false)
                        self.challengeHomeArea.pageControl.isHidden = true
                    }
                } else {
                    self.challengeHomeArea.setEmptyChallenge(isEmptyChallenge: false, isEmptyKeyword: false)
                    self.challengeHomeArea.pageControl.isHidden = false
                    
                    // 데이터가 있을 때만 높이 업데이트
                    // 컬렉션뷰 리로드 완료 후 높이 업데이트
                    DispatchQueue.main.async {
                        self.updateCollectionViewHeightAfterCellLayout(for: 0, animated: false)
                    }
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
extension ChallengeHomeAreaController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
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
        
        // 캐시된 높이가 있으면 사용
        if let cachedHeight = cellHeights[indexPath.row] {
            print("캐시된 셀 높이 사용: \(cachedHeight)")
            return CGSize(width: collectionView.frame.width, height: cachedHeight)
        }
        
        // 높이 계산
        let cellHeight = calculateCellHeight(for: challenge, collectionViewWidth: collectionView.frame.width)
        
        // 캐시에 저장
        cellHeights[indexPath.row] = cellHeight
        
        print("새로 계산된 셀 높이: \(cellHeight) (인덱스: \(indexPath.row))")
        
        return CGSize(width: collectionView.frame.width, height: cellHeight)
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
            presentSheet(verifyModalVC, heightRatio: 0.4, fixedHeight: 358)
        }
    }
    
    // 컬렉션뷰 레이아웃이 완료된 후 호출되는 delegate 메서드
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 첫 번째 셀이 표시될 때 컬렉션뷰 높이 업데이트
        if indexPath.row == selectedIndex && !todayChallenges.isEmpty {
            DispatchQueue.main.async {
                self.updateCollectionViewHeightAfterCellLayout(for: self.selectedIndex, animated: false)
            }
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
        
        let previousIndex = selectedIndex
        selectedIndex = indexPath.row
        challengeHomeArea.pageControl.currentPage = selectedIndex
        
        // 인덱스가 실제로 변경된 경우에만 높이 업데이트
        if previousIndex != selectedIndex {
            print("스크롤로 인한 인덱스 변경: \(previousIndex) -> \(selectedIndex)")
            updateCollectionViewHeightAfterCellLayout(for: selectedIndex, animated: true)
        }
    }
}
