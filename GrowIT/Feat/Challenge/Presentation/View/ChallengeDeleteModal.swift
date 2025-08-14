//
//  ChallengeDeleteModal.swift
//  GrowIT
//
//  Created by 허준호 on 1/24/25.
//

import UIKit

class ChallengeDeleteModal: UIView {

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
    
    private lazy var challengeDeleteIcon = UIImageView().then{
        $0.image = UIImage(named: "challengeDeleteIcon")
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var title1 = makeLabel(title: "정말 챌린지를 삭제할까요?", color: .gray900, font: .heading2Bold())
    
    private lazy var title2 = makeLabel(title: "삭제한 챌린지는 다시 복구하기 어렵습니다\n그래도 챌린지를 삭제할까요?", color: .gray700, font: .heading3SemiBold()).then{
        $0.numberOfLines = 2
    }
    
    public lazy var exitBtn = makeButton(title: "나가기", textColor: .gray400, bgColor: .gray100)
    
    public lazy var deleteBtn = makeButton(title: "삭제하기", textColor: .white, bgColor: .negative400)
    
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
        [grabberIcon, challengeDeleteIcon, title1, title2, btnStack].forEach(self.addSubview)
        [exitBtn, deleteBtn].forEach(btnStack.addArrangedSubview)
    }
    
    private func constraints(){
        
        grabberIcon.snp.makeConstraints{
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(80)
            $0.height.equalTo(4)
        }
        
        challengeDeleteIcon.snp.makeConstraints{
            $0.width.height.equalTo(28)
            $0.top.equalTo(grabberIcon.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(24)
        }
        
        title1.snp.makeConstraints{
            $0.top.equalTo(challengeDeleteIcon.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(24)
        }
        
        title2.snp.makeConstraints {
            $0.top.equalTo(title1.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(24)
            $0.height.equalTo(80)
        }
        
        exitBtn.snp.makeConstraints{
            $0.width.equalTo(88)
        }
        
        btnStack.snp.makeConstraints{
            $0.top.equalTo(title2.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }
        
    }
    

}
