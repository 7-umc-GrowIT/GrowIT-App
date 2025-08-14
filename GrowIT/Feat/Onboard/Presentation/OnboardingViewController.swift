//
//  OnboardingViewController.swift
//  GrowIT
//
//  Created by 허준호 on 2/6/25.
//

import UIKit

class OnboardingViewController: UIViewController {
    private lazy var onboardingView = OnboardingView()
    private lazy var pageControl = UIPageControl()
    private lazy var titles: [String] = ["챌린지를 완료하고\n내 캐릭터를 꾸며보세요!", "AI와 대화하면서\n감정 분석을 받아보세요!", "내 감정 상태에 맞는\n챌린지로 성장해요"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = onboardingView
        view.backgroundColor = .white
        
        setupPageControl()
        
        onboardingView.imageCollectionView.dataSource = self
        onboardingView.imageCollectionView.delegate = self
        
        onboardingView.startBtn.addTarget(self, action: #selector(goToAuth), for: .touchUpInside)
        onboardingView.loginBtn.addTarget(self, action: #selector(goToLogin), for:.touchUpInside)
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = 3  // 페이지 수 설정
        pageControl.currentPage = 0    // 현재 페이지 초기화
        pageControl.currentPageIndicatorTintColor = .primary600
        pageControl.pageIndicatorTintColor = .gray
        view.addSubview(pageControl)

        //pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.snp.makeConstraints {
            $0.top.equalTo(onboardingView.imageCollectionView.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
        }
        
        onboardingView.title.snp.remakeConstraints {
            $0.top.equalTo(pageControl.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
        }
    }
    
    @objc private func goToAuth() {
        let nextVC = TermsAgreeViewController()
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc private func goToLogin() {
        let nextVC = LoginViewController()
        navigationController?.pushViewController(nextVC, animated: true)
    }
}

extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingImageCell.identifier, for: indexPath) as? OnboardingImageCell else { return UICollectionViewCell() }
        
        cell.figure(index: indexPath.row + 1)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width  // collectionView의 전체 너비
        let height = collectionView.bounds.height
        
        return CGSize(width: width, height: height)
    }
    
    /// 섹션 여백
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // 섹션의 여백 설정
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: onboardingView.imageCollectionView.contentOffset, size: onboardingView.imageCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        if let visibleIndexPath = onboardingView.imageCollectionView.indexPathForItem(at: visiblePoint) {
            pageControl.currentPage = visibleIndexPath.row
            print("Current visible cell index: \(visibleIndexPath.row)")
            // 여기서 필요한 작업 수행, 예를 들면 인덱스 저장, UI 업데이트 등
            onboardingView.title.text = titles[visibleIndexPath.row]
            self.view.layoutIfNeeded()
        }
    }
}
