//
//  ChallengeStatusAreaController.swift
//  GrowIT
//
//  Created by 허준호 on 1/23/25.
//

import UIKit
import Combine

final class ChallengeStatusAreaController: UIViewController {
    
    // MARK: - Properties
    private let challengeStatusArea = ChallengeStatusArea()
    private let viewModel: ChallengeStatusViewModel
    
    private let challengeStatusType: [String] = ["전체", "완료", "랜덤 챌린지", "데일리 챌린지"]
    private var selectedStatusIndex: Int = 0
    private var selectedChallenge: UserChallenge?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(viewModel: ChallengeStatusViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = challengeStatusArea
        view.backgroundColor = .gray50
        
        setupCollections()
        setupNotifications()
        bindViewModel()
        viewModel.fetchChallengesForStatus(index: 0, page: 1) // 진입 시 1페이지 조회
    }
    
    // MARK: - Setup
    private func setupCollections() {
        // 버튼 그룹은 CollectionView 유지
        challengeStatusArea.challengeStatusBtnGroup.dataSource = self
        challengeStatusArea.challengeStatusBtnGroup.delegate = self
        challengeStatusArea.challengeStatusBtnGroup.tag = 2
        
        // 챌린지 목록은 TableView로 바인딩
        challengeStatusArea.challengeAllList.dataSource = self
        challengeStatusArea.challengeAllList.delegate = self
        challengeStatusArea.challengeAllList.tag = 1
        
        // 페이지네이터 클릭 클로저 바인딩
        challengeStatusArea.onPageSelected = { [weak self] page in
            self?.viewModel.moveToPage(page)
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToVerify), name: NSNotification.Name("navigateToChallengeVerify"), object: nil)
    }
    
    @objc private func navigateToVerify() {
        guard !view.isHidden else { return }
        let challengeVerifyVC = ChallengeVerifyViewController(challenge: selectedChallenge)
        navigationController?.pushViewController(challengeVerifyVC, animated: true)
    }
    
    private func bindViewModel() {
        viewModel.$challenges
            .receive(on: RunLoop.main)
            .sink { [weak self] challenges in
                self?.challengeStatusArea.challengeAllList.reloadData()
                self?.scrollToTop()
            
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { error in
                print("Error: \(error)")
            }
            .store(in: &cancellables)
        
        viewModel.$page
            .receive(on: RunLoop.main)
            .sink { [weak self] page in
                self?.challengeStatusArea.currentPage = page
            }
            .store(in: &cancellables)
        
        viewModel.$totalPages
            .receive(on: RunLoop.main)
            .sink { [weak self] totalPages in
                self?.challengeStatusArea.totalPage = totalPages
            }
            .store(in: &cancellables)
        
        viewModel.$totalElements
            .receive(on: RunLoop.main)
            .sink { [weak self] totalElements in
                self?.challengeStatusArea.challengeStatusNum.text = "\(totalElements)"
                
                if totalElements == 0 {
                    self?.challengeStatusArea.showEmptyChallenge(true)
                }else {
                    self?.challengeStatusArea.showEmptyChallenge(false)
                }
            }
            .store(in: &cancellables)
    }
    
    public func refreshData() {
        viewModel.refresh()
    }
    
    private func scrollToTop() {
        let tableView = challengeStatusArea.challengeAllList
        if tableView.numberOfSections > 0, tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        } else {
            tableView.setContentOffset(.zero, animated: false)
        }
    }
}

// MARK: - 버튼 그룹 CollectionView (상단 필터/상태용)
extension ChallengeStatusAreaController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return challengeStatusType.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChallengeStatusBtnGroupCell.identifier, for: indexPath) as? ChallengeStatusBtnGroupCell else {
            return UICollectionViewCell()
        }
        let isSelected = indexPath.row == selectedStatusIndex
        cell.figure(titleText: challengeStatusType[indexPath.row], isClicked: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = challengeStatusType[indexPath.row]
        let font = UIFont.heading3SemiBold()
        let textWidth = title.size(withAttributes: [.font: font]).width
        let cellWidth = textWidth + 32
        return CGSize(width: cellWidth, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedStatusIndex = indexPath.row
        viewModel.fetchChallengesForStatus(index: selectedStatusIndex)
        collectionView.reloadData()
        challengeStatusArea.challengeAllList.reloadData()
        scrollToTop()
    }
}

// MARK: - 챌린지 리스트 TableView
extension ChallengeStatusAreaController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.challenges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomChallengeListCell.identifier, for: indexPath) as? CustomChallengeListCell else {
            return UITableViewCell()
        }
        let challenge = viewModel.challenges[indexPath.row]
        cell.figure(challenge: challenge)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedChallenge = viewModel.challenges[indexPath.row]
        if challengeStatusType[selectedStatusIndex] == "완료" {
            let challengeCompleteVC = ChallengeCompleteViewController()
            challengeCompleteVC.challengeId = selectedChallenge!.id
            presentSheet(challengeCompleteVC, heightRatio: 1, useLargeOnly: true)
        } else {
            let challengeVerifyModalVC = ChallengeVerifyModalController()
            challengeVerifyModalVC.modalPresentationStyle = .pageSheet
            presentSheet(challengeVerifyModalVC, heightRatio: 0.4)
            challengeVerifyModalVC.challengeId = selectedChallenge!.id
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let challenge = viewModel.challenges[indexPath.row]
        
        let label = UILabel()
        label.font = .heading3Bold()
        label.numberOfLines = 0
        label.text = challenge.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let availableWidth = tableView.frame.width * 0.45 // name label 제약과 동일
        let size = label.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude))
        
        let titleHeight = size.height
        let baseHeight: CGFloat = 78 // top + spacing + bottom inset
        return max(100, titleHeight + baseHeight)
    }

}
