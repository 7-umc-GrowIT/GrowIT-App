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
        
        setupCollectionView()
        bindViewModel()
        viewModel.moveToPage(1) // 진입 시 1페이지 조회
    }
    
    // MARK: - Setup
    private func setupCollectionView() {
        challengeStatusArea.challengeStatusBtnGroup.dataSource = self
        challengeStatusArea.challengeStatusBtnGroup.delegate = self
        challengeStatusArea.challengeStatusBtnGroup.tag = 2
        
        challengeStatusArea.challengeAllList.dataSource = self
        challengeStatusArea.challengeAllList.delegate = self
        challengeStatusArea.challengeAllList.tag = 1
        
        // 페이지네이터 클릭 클로저 바인딩
        challengeStatusArea.onPageSelected = { [weak self] page in
            self?.viewModel.moveToPage(page)
        }
    }
    
    private func bindViewModel() {
        viewModel.$challenges
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.challengeStatusArea.challengeAllList.reloadData()
                self?.challengeStatusArea.challengeStatusNum.text = "\(self?.viewModel.challenges.count ?? 0)"
                self?.scrollToTop()
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { error in
                // TODO: 에러 표시(알림 등)
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
    }
    
    public func refreshData() {
        viewModel.refresh()
    }
    
    private func scrollToTop() {
        let collectionView = challengeStatusArea.challengeAllList
        if collectionView.numberOfSections > 0, collectionView.numberOfItems(inSection: 0) > 0 {
            // 첫 번째 셀로 스크롤 (애니메이션 없이)
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        } else {
            // 혹시 셀 없으면 그냥 offset만 0으로
            collectionView.setContentOffset(.zero, animated: false)
        }
    }

}

// MARK: - UICollectionViewDataSource, Delegate
extension ChallengeStatusAreaController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 1:
            return viewModel.challenges.count
        case 2:
            return challengeStatusType.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomChallengeListCell.identifier, for: indexPath) as? CustomChallengeListCell else {
                return UICollectionViewCell()
            }
            let challenge = viewModel.challenges[indexPath.row]
            cell.figure(challenge: challenge)
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChallengeStatusBtnGroupCell.identifier, for: indexPath) as? ChallengeStatusBtnGroupCell else {
                return UICollectionViewCell()
            }
            let isSelected = indexPath.row == selectedStatusIndex
            cell.figure(titleText: challengeStatusType[indexPath.row], isClicked: isSelected)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView.tag {
        case 1:
            let challenge = viewModel.challenges[indexPath.row]
            let approximateWidthOfNameLabel = collectionView.frame.width * 0.5 // 아이콘, 패딩을 고려한 너비
            let size = CGSize(width: approximateWidthOfNameLabel, height: CGFloat.greatestFiniteMagnitude)
            let attributes = [NSAttributedString.Key.font: UIFont.heading3Bold()]
            
            let estimatedFrame = NSString(string: challenge.title).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
            let lines = ceil(estimatedFrame.height / UIFont.heading3Bold().lineHeight) // 줄 수 계산
            let additionalHeightPerLine = UIFont.heading3Bold().lineHeight // 추가 높이 설정
            
            let cellHeight = 78 + (lines * additionalHeightPerLine) // 기본 높이 + 줄 수에 따른 추가 높이
            return CGSize(width: collectionView.frame.width, height: cellHeight)
        case 2:
            // 버튼 그룹 셀은 기존 스타일대로 텍스트 너비+패딩으로
            let title = challengeStatusType[indexPath.row]
            let font = UIFont.heading3SemiBold()
            let textWidth = title.size(withAttributes: [.font: font]).width
            let cellWidth = textWidth + 32
            return CGSize(width: cellWidth, height: 40)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case 1:
            selectedChallenge = viewModel.challenges[indexPath.row]
            if(challengeStatusType[selectedStatusIndex] == "완료"){
                let challengeCompleteVC = ChallengeCompleteViewController()
                
                challengeCompleteVC.challengeId = selectedChallenge!.id
                challengeCompleteVC.modalPresentationStyle = .pageSheet
                
                presentSheet(challengeCompleteVC, heightRatio: 0.9)
            }else{
                let challengeVerifyModalVC = ChallengeVerifyModalController()
                
                challengeVerifyModalVC.modalPresentationStyle = .pageSheet
                challengeVerifyModalVC.delegate = self
                
                presentSheet(challengeVerifyModalVC, heightRatio: 0.34)
                
                challengeVerifyModalVC.challengeId = selectedChallenge!.id
            }
        case 2:
            selectedStatusIndex = indexPath.row
            switch indexPath.row {
            case 0: // 전체
                viewModel.selectedType = .all
                viewModel.completed = false
            case 1: // 완료
                viewModel.selectedType = .all
                viewModel.completed = true
            case 2: // 랜덤 챌린지
                viewModel.selectedType = .random
                viewModel.completed = false
            case 3: // 데일리 챌린지
                viewModel.selectedType = .daily
                viewModel.completed = false
            default:
                break
            }
            
            viewModel.page = 1
            
            collectionView.reloadData()
            challengeStatusArea.challengeAllList.reloadData()
            scrollToTop()
        default:
            break
        }
    }
}

extension ChallengeStatusAreaController: ChallengeVerifyModalDelegate {
    func didRequestVerification() {
        if let challenge = selectedChallenge {
            self.dismiss(animated: true, completion: {
                let nextVC = ChallengeVerifyViewController()
                
                self.navigationController?.pushViewController(
                    nextVC, animated: true
                )
            })
        }
    }
}

