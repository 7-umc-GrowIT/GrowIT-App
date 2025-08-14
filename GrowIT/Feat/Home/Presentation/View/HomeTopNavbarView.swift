//
//  HomeTopNavbarView.swift
//  GrowIT
//
//  Created by 허준호 on 1/8/25.
//

import UIKit

class HomeTopNavbarView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        addStackView()
        addComponents()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Property
    
    // 제목로고 이미지 뷰
    private lazy var titleLogo = UIImageView().then{
        $0.image = UIImage(named: "titleLogo")
        $0.contentMode = .scaleAspectFit
    }
    
    // 아이템샵 아이콘 버튼
    public lazy var itemShopBtn = makeIconbutton(image: "shop")
    
    // 환경설정 아이콘 버튼
    public lazy var settingBtn = makeIconbutton(image: "setting")
    
    // MARK: - Stack
    
    // 아이템샵 버튼 + 환경설정 버튼 가로 스택뷰
    private lazy var topNavIconsStackView = makeStackView(axis: .horizontal, spacing: 15)
    
    // MARK: - Function
    
    // 아이콘 버튼 생성 함수
    private func makeIconbutton(image: String) -> UIButton{
        let iconBtn = UIButton()
        iconBtn.setImage(UIImage(named: image), for: .normal)
        iconBtn.imageView?.contentMode = .scaleAspectFit
        return iconBtn
    }
    
    // 스택뷰 생성 함수
    private func makeStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat) -> UIStackView{
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.distribution = .equalSpacing
        return stackView
    }
    
    // MARK: - add Function & constraints
    
    private func addStackView(){
        [itemShopBtn, settingBtn].forEach(topNavIconsStackView.addArrangedSubview)
    }
    
    private func addComponents(){
        [titleLogo, topNavIconsStackView].forEach(self.addSubview)
    }
    
    private func constraints(){
        
        titleLogo.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(18)
            $0.left.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.2)
            $0.height.equalToSuperview().multipliedBy(0.4)
        }
        
        itemShopBtn.snp.makeConstraints {
            $0.width.height.equalTo(36)
        }
        
        settingBtn.snp.makeConstraints {
            $0.width.height.equalTo(36)
        }
        
        topNavIconsStackView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(12)
            $0.right.equalToSuperview()
        }
    }
}
