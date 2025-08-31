//
//  FriendReadyModalView.swift
//  GrowIT
//
//  Created by 허준호 on 8/31/25.
//

import UIKit
import Then
import SnapKit

class FriendReadyModalView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Property
    private let grabberIcon = UIImageView().then {
        $0.image = UIImage(named: "grabberIcon")
        $0.contentMode = .scaleAspectFit
    }
    
    private let warningIcon = UIImageView().then {
        $0.image = UIImage(named: "warning")
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var title = makeLabel(title: "친구 기능은 아직 준비중이에요", color: .gray900, font: .heading2Bold())
    
    private lazy var subTitle = makeLabel(title: "친구를 맺고 함께 활동을 즐길 수 있는 기능이 추가될 예정이에요! 조금만 기다려 주세요!", color: .gray600, font: .heading3SemiBold()).then {
        $0.numberOfLines = 2
    }
    
    public lazy var checkButton = makeButton(title: "확인했어요", textColor: .white, bgColor: .black)
    
    // MARK: - Func
    private func makeLabel(title:String, color: UIColor, font: UIFont) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textColor = color
        label.font = font
        label.adjustsFontSizeToFitWidth = true
        return label
    }
    
    private func makeStack(axis: NSLayoutConstraint.Axis, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        return stackView
    }
    
    private func makeButton(title:String, textColor: UIColor, bgColor: UIColor) -> UIButton {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = bgColor
        config.baseForegroundColor = textColor
        config.cornerStyle = .fixed
        config.background.cornerRadius = 16
        
        var attributedTitle = AttributedString(title)
        attributedTitle.font = .heading2Bold()
        config.attributedTitle = attributedTitle
        
        // 세로 패딩 17 설정
        config.contentInsets = NSDirectionalEdgeInsets(top: 17, leading: 0, bottom: 17, trailing: 0)
        
        button.configuration = config
        
        return button
    }
    
    private func setUpView() {
        self.addSubviews([grabberIcon, warningIcon, title, subTitle, checkButton])
        
        grabberIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.width.equalTo(80)
            $0.height.equalTo(4)
            $0.centerX.equalToSuperview()
        }
        
        warningIcon.snp.makeConstraints {
            $0.top.equalTo(grabberIcon.snp.bottom).offset(24)
            $0.width.height.equalTo(28)
            $0.left.equalToSuperview().offset(24)
        }
        
        title.snp.makeConstraints {
            $0.top.equalTo(warningIcon.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(24)
        }
        
        subTitle.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.centerX.equalToSuperview()
        }
        
        checkButton.snp.makeConstraints {
            $0.top.equalTo(subTitle.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.centerX.equalToSuperview()
        }
    }
}
