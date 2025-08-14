//
//  GroSetBackgroundViewController.swift
//  GrowIT
//
//  Created by 오현민 on 1/12/25.
//

import UIKit
import SnapKit

class GroSetBackgroundViewController: UIViewController, ItemBackgroundModalDelegate {
    private var itemListBottomConstraint: Constraint?
    private var isZoomIn: Bool = true
    var selectedBackground: Int = 0
    
    //MARK: - Views
    // 그로 화면
    private lazy var groView = GroView().then {
        $0.eraseButton.isHidden = true
        $0.zoomButton.addTarget(self, action: #selector(didTapZoomButton), for: .touchUpInside)
        $0.purchaseButton.addTarget(self, action: #selector(nextVC), for: .touchUpInside)
    }
    // 아이템샵 모달 화면
    private lazy var itemBackgroundModalVC = ItemBackgroundModalViewController()
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = groView
        
        setView()
        setConstraints()
        setInitialState()
        
        navigationController?.navigationBar.isHidden = true
        itemBackgroundModalVC.delegate = self
    }
    
    //MARK: - 컴포넌트추가
    private func setView() {
        addChild(itemBackgroundModalVC)
        groView.addSubview(itemBackgroundModalVC.view)
        itemBackgroundModalVC.didMove(toParent: self)
    }
    
    //MARK: - 레이아웃설정
    private func setConstraints() {
        itemBackgroundModalVC.view.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.47)
            self.itemListBottomConstraint = $0.bottom.equalToSuperview().offset(0).constraint
        }
    }
    
    //MARK: - 기능구현
    @objc
    private func didTapZoomButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        updateItemListPosition(isZoomedOut: sender.isSelected)
        updateButtonStackViewPosition(isZoomedOut: sender.isSelected)
        updateZoomButtonImage(isZoomedOut: sender.isSelected)
        updateGroImageViewTopConstraint(isZoomedOut: sender.isSelected)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func nextVC() {
        let nextVC = GroSetNameViewController(selectedBackground: selectedBackground)
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    //MARK: - UI 업데이트 함수
    private func updateItemListPosition(isZoomedOut: Bool) {
        let offset = isZoomedOut ? 500 : 0
        self.itemListBottomConstraint?.update(offset: offset)
    }
    
    private func updateButtonStackViewPosition(isZoomedOut: Bool) {
        groView.buttonStackView.snp.remakeConstraints {
            let bottomConstraint = isZoomedOut
            ? groView.purchaseButton.snp.top
            : itemBackgroundModalVC.view.snp.top
            $0.bottom.equalTo(bottomConstraint).offset(-24)
            $0.trailing.equalToSuperview().inset(24)
        }
    }
    
    private func updateZoomButtonImage(isZoomedOut: Bool) {
        let imageName = isZoomedOut ? "GrowIT_ZoomIn" : "GrowIT_ZoomOut"
        groView.zoomButton.configuration?.image = UIImage(named: imageName)
    }
    
    private func updateGroImageViewTopConstraint(isZoomedOut: Bool) {
        let inset = isZoomedOut ? 168 : 40
        groView.groImageViewTopConstraint?.update(inset: inset)
    }
    
    private func setInitialState() {
        groView.buttonStackView.snp.remakeConstraints {
            $0.bottom.equalTo(itemBackgroundModalVC.view.snp.top).offset(-24)
            $0.trailing.equalToSuperview().inset(24)
        }
    }
    
    // MARK: - ItemBackgroundModalDelegate 구현
    func updateBackgroundImage(to index: Int) {
        let images: [UIImage?] = [
            UIImage.growITBackgroundStar,
            UIImage.growITBackgroundTree,
            UIImage.growITBackgroundHeart
        ]
        groView.backgroundImageView.image = images[index]
        selectedBackground = index
    }
}
