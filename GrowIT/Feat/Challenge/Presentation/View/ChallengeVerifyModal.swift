//
//  ChallengeVerifyModal.swift
//  GrowIT
//
//  Created by 허준호 on 1/24/25.
//

import UIKit
import Then
import SnapKit

class ChallengeVerifyModal: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addComponents()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Property
    private lazy var grabberIcon = UIImageView().then{
        $0.image = UIImage(named: "grabberIcon")
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var challengeIcon = UIImageView().then{
        $0.image = UIImage(named: "challengeIcon")
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var title1 = makeLabel(title: "아직 인증이 안 된 챌린지에요", color: .gray900, font: .heading2Bold())
    
    private lazy var title2 = makeLabel(title: "챌린지를 인증하면 크레딧을 받을 수 있어요\n챌린지를 인증하러 갈까요?", color: .gray700, font: .heading3SemiBold()).then{
        $0.numberOfLines = 2
    }
    
    public lazy var exitBtn = makeButton(title: "나가기", textColor: .gray400, bgColor: .gray100)
    
    public lazy var verifyBtn = makeButton(title: "인증하기", textColor: .white, bgColor: .black)
    
    public lazy var deleteBtn = UIButton().then{
        $0.setTitle("삭제하기", for: .normal)
        $0.setTitleColor(.gray400, for: .normal)
        $0.titleLabel?.font = .body2Medium()
    }
    // MARK: - Stack
    private lazy var btnStack = makeStack(axis: .horizontal, spacing: 8)
    
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
        stackView.distribution = .fillEqually
        return stackView
    }
    
    private func makeButton(title:String, textColor: UIColor, bgColor: UIColor) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.titleLabel?.font = .heading2Bold()
        button.backgroundColor = bgColor
        button.layer.cornerRadius = 16
        return button
    }
    
    // MARK: - addFunc & Constraints
    
    private func addComponents(){
        [grabberIcon, challengeIcon, title1, title2, btnStack, deleteBtn].forEach(self.addSubview)
        [exitBtn, verifyBtn].forEach(btnStack.addArrangedSubview)
    }
    
    private func constraints(){
        
        grabberIcon.snp.makeConstraints{
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(80)
            $0.height.equalTo(4)
        }
        
        challengeIcon.snp.makeConstraints{
            $0.width.height.equalTo(28)
            $0.top.equalTo(grabberIcon.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(24)
        }
        
        title1.snp.makeConstraints{
            $0.top.equalTo(challengeIcon.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(24)
        }
        
        title2.snp.makeConstraints {
            $0.top.equalTo(title1.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(24)
        }
        
        btnStack.snp.makeConstraints{
            $0.top.equalTo(title2.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }
        
        deleteBtn.snp.makeConstraints{
            $0.top.equalTo(btnStack.snp.bottom).offset(15.5)
            $0.centerX.equalToSuperview()
        }
    }
    
}
