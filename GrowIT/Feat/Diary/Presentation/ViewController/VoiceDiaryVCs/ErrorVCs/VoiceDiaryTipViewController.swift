//
//  VoiceDiaryTipViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/18/25.
//

import UIKit

class VoiceDiaryTipViewController: UIViewController {
    
    // MARK: Properties
    let voicDiaryTipView = VoiceDiaryTipView()
    let pageControl = UIPageControl()
    var currentIndex: Int = 0
    
    private var tips: [TipItem] = [
        TipItem(image: UIImage(named: "voiceDiaryTip1")!, content: "음성 통화가 시작되면 AI가 먼저 말을 걸어와요\nAI의 질문에 일기 쓰기를 시작해봐요"),
        TipItem(image: UIImage(named: "voiceDiaryTip2")!, content: "대답의 공백이 길어지면 AI가 응답을 해요\n할 말이 남았다면 버튼을 눌러 다시 대답해보세요!"),
        TipItem(image: UIImage(named: "voiceDiaryTip3")!, content: "AI와 대화는 최소 1분, 최대 3분까지 할 수 있어요\n대화 종료는 1분이 지난 후부터 가능해요"),
        TipItem(image: UIImage(named: "voiceDiaryTip4")!, content: "충분히 대화를 나누고\nAI가 작성한 일기를 확인해 보세요"),
        TipItem(image: UIImage(named: "voiceDiaryTip5")!, content: "일기를 저장하면 내 감정에 맞는 챌린지를\n추천 받을 수 있어요"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        
        voicDiaryTipView.contentView.delegate = self
        voicDiaryTipView.contentView.dataSource = self
    
        setPageControl()
    }
    
    
    private func setPageControl() {
        pageControl.currentPage = currentIndex
        pageControl.numberOfPages = 5
        pageControl.currentPageIndicatorTintColor = .primary400
        pageControl.pageIndicatorTintColor = .gray400
        
        voicDiaryTipView.addSubview(pageControl)
        pageControl.snp.makeConstraints {
            $0.top.equalTo(voicDiaryTipView.contentView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        voicDiaryTipView.exitButton.snp.remakeConstraints {
            $0.top.equalTo(pageControl.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(60)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
    }
    
    // MARK: Setup UI
    private func setupUI() {
        view.addSubview(voicDiaryTipView)
        voicDiaryTipView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: Setup Actions
    private func setupActions() {
        voicDiaryTipView.exitButton.addTarget(self, action: #selector(prevVC), for: .touchUpInside)
    }
    
    // MARK: @objc methods
    @objc func prevVC() {
        dismiss(animated: true)
    }
    
}

extension VoiceDiaryTipViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tips.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: VoiceDiaryTipCell.identifier,
            for: indexPath
        ) as? VoiceDiaryTipCell else { return UICollectionViewCell() }
        
        let tip = tips[indexPath.item]
        cell.configure(with: tip)
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = page
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("collectionView.bounds:", collectionView.bounds)
        print("cell frame:", collectionView.cellForItem(at: indexPath)?.frame ?? "n/a")
        return CGSize(width: collectionView.bounds.width,
                          height: 320)
    }
}
