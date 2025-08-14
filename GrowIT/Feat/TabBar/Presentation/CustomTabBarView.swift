//
//  CustomTabBarView.swift
//  GrowIT
//
//  Created by 허준호 on 1/9/25.
//

import UIKit
import Then
import SnapKit

class CustomTabBarView: UIView {
    
    var didSelectItem: ((Int) -> Void)? // 탭 선택 콜백
    var selectedIndex: Int = 1 // 기본 선택 인덱스
    
    override init(frame: CGRect) {
        super.init(frame: frame)
      
        addStackView()
        addComponent()
        constraints()
        configureTapGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Property
    
    // 탭바 배경 이미지
    
    public lazy var containerView = UIView().then{
        $0.backgroundColor = .clear
    }
    
    private lazy var tabBarBg = UIImageView().then{
        $0.image = UIImage(named: "tabBarBg")
        $0.contentMode = .scaleAspectFill
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowRadius = 10
        $0.layer.shadowOffset = CGSize(width: 0, height: 0)
        $0.layer.shadowOpacity = 0.16
        $0.layer.masksToBounds = false
        
        $0.layer.shouldRasterize = true
        $0.layer.rasterizationScale = UIScreen.main.scale
        $0.isUserInteractionEnabled = true
    }
    
    
    // 첫번째 아이템 아이콘
    private lazy var firstTabIcon = makeTabItem(image: "diary",color: UIColor.grayColor300!)
    
    // 첫번째 아이템 라벨
    private lazy var firstTabLabel = makeLabel(name:"일기", color: UIColor.grayColor400!)

    
    
    private lazy var secondTabItem = UIImageView().then{
        $0.image = UIImage(named: "homeSelected")
        $0.contentMode = .scaleAspectFit
    }
    
    // 세번째 아이템 아이콘
    private lazy var thirdTabIcon = makeTabItem(image: "challenge", color: UIColor.grayColor300!)
    
    // 첫번째 아이템 라벨
    private lazy var thirdTabLabel = makeLabel(name:"챌린지", color: UIColor.grayColor400!)
    
    // MARK: - Stack
    
    // 첫번째 탭바 아이템
    private lazy var firstTabItem = makeStackView(2)
    
    // 세번째 탭바 아이템
    private lazy var thirdTabItem = makeStackView(2)
    
    
    // MARK: - Function
    
    private func makeTabItem(image: String, color: UIColor) -> UIButton {
        let item = UIButton()
        item.setImage(UIImage(named: image)?.withRenderingMode(.alwaysTemplate), for: .normal)
        item.contentMode = .scaleAspectFit
        item.tintColor = color
        item.isUserInteractionEnabled = false
        return item
    }
    
    private func makeLabel(name: String, color:UIColor) -> UILabel{
        let label = UILabel()
        label.text = name
        label.textColor = color
        label.font = UIFont.body2Medium()
        label.textAlignment = .center
        return label
    }
    
    private func makeStackView(_ spacing: CGFloat) -> UIStackView{
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = spacing
        return stackView
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 컨테이너 뷰의 하위 레이어에 대해 반복하여 그라디언트 레이어의 크기를 업데이트
        self.subviews.forEach { subview in
            if let gradientLayer = (subview.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer) {
                gradientLayer.frame = subview.bounds
            }
        }
        
        self.setNeedsUpdateConstraints()
    }

    
    // MARK: - add Function & Constraints
    
    private func addStackView(){
        [firstTabIcon, firstTabLabel].forEach(firstTabItem.addArrangedSubview)
        //[secondTabIcon, secondTabLabel].forEach(secondTabItem.addArrangedSubview)
        [thirdTabIcon, thirdTabLabel].forEach(thirdTabItem.addArrangedSubview)
    }
    
    private func addComponent(){
        self.addSubview(containerView)

        [tabBarBg, firstTabItem, secondTabItem, thirdTabItem].forEach(containerView.addSubview)
        
    }
    
    private func constraints(){
        
        containerView.snp.makeConstraints{
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalToSuperview()
        }
        
        tabBarBg.snp.makeConstraints{
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        firstTabIcon.snp.makeConstraints{
            $0.height.width.equalTo(40)
        }
        
        firstTabItem.snp.makeConstraints {
            $0.centerX.equalToSuperview().multipliedBy(1.0 / 3.0)
            $0.centerY.equalTo(tabBarBg.snp.centerY)
        }
        
        thirdTabIcon.snp.makeConstraints{
            $0.height.width.equalTo(40)
        }
        
        thirdTabItem.snp.makeConstraints {
            $0.centerX.equalToSuperview().multipliedBy(5.0 / 3.0)
            $0.centerY.equalTo(tabBarBg.snp.centerY)
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        secondTabItem.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            //$0.top.equalTo(tabBarBg.snp.top).offset(self.frame.height * 0.54 * -1)
            $0.top.equalTo(tabBarBg.snp.top).offset(-54)
            $0.width.equalToSuperview().multipliedBy(0.3)
        }
    }
    
    private func configureTapGestures() {
        let firstItemGesture = UITapGestureRecognizer(target: self, action: #selector(didTapFirstItem))
        let secondItemGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSecondItem))
        let thirdItemGesture = UITapGestureRecognizer(target: self, action: #selector(didTapThirdItem))
        firstTabItem.addGestureRecognizer(firstItemGesture)
        secondTabItem.isUserInteractionEnabled = true
        secondTabItem.addGestureRecognizer(secondItemGesture)
        thirdTabItem.addGestureRecognizer(thirdItemGesture)
    }
    
    // 탭 아이템 업데이트 메소드
    func updateTabItemSelection(at index: Int) {
        selectedIndex = index

        // 아이템 색상 업데이트
        firstTabIcon.tintColor = (index == 0) ? .primaryColor600 : .grayColor300
        firstTabLabel.textColor = (index == 0) ? .grayColor900 : .grayColor400
        
        secondTabItem.image = (index == 1) ? UIImage(named: "homeSelected") : UIImage(named: "homedeSelected")
        
        thirdTabIcon.tintColor = (index == 2) ? .primaryColor600 : .grayColor300
        thirdTabLabel.textColor = (index == 2) ? .grayColor900 : .grayColor400
    }

    @objc private func didTapFirstItem() {
        didSelectItem?(0)
        updateTabItemSelection(at: 0)
    }

    @objc private func didTapSecondItem() {
        didSelectItem?(1)
        updateTabItemSelection(at: 1)
    }

    @objc private func didTapThirdItem() {
        didSelectItem?(2)
        updateTabItemSelection(at: 2)
    }
}
