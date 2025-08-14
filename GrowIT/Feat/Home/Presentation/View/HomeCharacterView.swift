//
//  HomeCharacterView.swift
//  GrowIT
//
//  Created by 허준호 on 1/9/25.
//

import UIKit

class HomeCharacterView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addStackView()
        addComponents()
        constraints()
        setGroLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Property
    
    // 배경
    var backgroundImageView = UIImageView().then{
        $0.contentMode = .scaleToFill
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // 크레딧 아이콘
    private lazy var creditIcon = makeIcon("credit")
    
    // 크레딧 개수
    public lazy var creditNum = UILabel().then{
        $0.text = "1개"
        $0.font = UIFont.heading2Bold()
        $0.textColor = .white
    }
    
    // 크레딧 컨테이너
    private lazy var creditContainer = makeContainer()
    
    // 친구보기 버튼 아이콘
    private lazy var friendIcon = makeIcon("friend")
    
    // 친구보기 버튼 컨테이너
    private lazy var friendContainer = makeContainer()
    
    // 캐릭터 이미지
    private lazy var groFrameView = UIView().then {
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    var groFaceImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var groFlowerPotImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var groAccImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var groObjectImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // 하단 그라디언트 뷰
    private lazy var bottomGradientView = UIImageView().then{
        $0.image = UIImage(named: "homeGradient")
        $0.contentMode = .scaleAspectFill
    }
    
    // MARK: - Stack
    
    // 크레딧 개수 가로 스택
    private lazy var creditBoxStack = makeStackView(axis: .horizontal, spacing: 12)
    
    
    // MARK: - Function
    
    // 스택뷰 생성 함수(스택 방향, 간격)
    private func makeStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat) -> UIStackView{
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.distribution = .equalSpacing
        return stackView
    }
    
    // 아이콘 생성 함수
    private func makeIcon(_ name:String) -> UIImageView{
        let icon = UIImageView()
        icon.image = UIImage(named: name)
        icon.contentMode = .scaleAspectFit
        return icon
    }
    
    // 크레딧 개수 박스, 친구보기 버튼 박스
    // 공통 컨테이너 박스 생성
    private func makeContainer() -> UIView{
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.6)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }
    
    private func setGroLayer() {
        groFlowerPotImageView.layer.zPosition = 0
        groFaceImageView.layer.zPosition = 1
        groAccImageView.layer.zPosition = 2
        groObjectImageView.layer.zPosition = 3
    }
    
    // MARK: - add Function & Constraints
    
    private func addStackView(){
        [creditIcon, creditNum].forEach(creditBoxStack.addArrangedSubview)
    }
    
    private func addComponents(){
        creditContainer.addSubview(creditBoxStack)
        friendContainer.addSubview(friendIcon)
        [backgroundImageView, groFrameView, creditContainer, friendContainer, bottomGradientView].forEach(self.addSubview)
        
        groFrameView.addSubviews([
            groFaceImageView,
            groFlowerPotImageView,
            groAccImageView,
            groObjectImageView
        ])
    }
    
    private func constraints(){
        
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        creditContainer.snp.makeConstraints{
            $0.top.equalToSuperview().offset(24)
            $0.left.equalToSuperview().offset(24)
        }
        
        creditBoxStack.snp.makeConstraints{
            $0.edges.equalToSuperview().inset(15)
        }
        
        friendContainer.snp.makeConstraints{
            $0.top.equalToSuperview().offset(24)
            $0.right.equalToSuperview().inset(24)
        }
        
        friendIcon.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(15)
            $0.height.width.equalTo(28)
        }
        
        groFrameView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(1.3)
            $0.height.equalTo(groFrameView.snp.width)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(62)
        }
        
        [groFaceImageView, groFlowerPotImageView, groAccImageView, groObjectImageView].forEach {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        bottomGradientView.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.35)
            $0.width.equalToSuperview().multipliedBy(1)
        }
    }
    
}
