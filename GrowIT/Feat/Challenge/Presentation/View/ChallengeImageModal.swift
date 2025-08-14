//
//  ChallengeImageModal.swift
//  GrowIT
//
//  Created by 허준호 on 1/29/25.
//

import UIKit
import Then
import SnapKit

class ChallengeImageModal: UIView {

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
    
    private lazy var cameraIcon = UIImageView().then{
        $0.image = UIImage(named: "cameraIcon")
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var title = makeLabel(title: "인증샷을 업로드할게요", color: .gray900, font: .heading2Bold())
    
    private lazy var subTitle = makeLabel(title: "어떻게 인증샷을 업로드할까요?", color: .gray600, font: .heading3SemiBold())
    
    public lazy var cameraBtn = makeButton(title: "카메라로 촬영하기", textColor: .white, bgColor: .black)
    
    public lazy var galleryBtn = makeButton(title: "갤러리에서 선택하기", textColor: .white, bgColor: .black)
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
    
    // MARK: - addFunc & constraints
    
    private func addComponents() {
        [grabberIcon, cameraIcon, title, subTitle, cameraBtn, galleryBtn].forEach(self.addSubview)
    }
    
    private func constraints(){
        grabberIcon.snp.makeConstraints {
            $0.top.equalTo(self).offset(24)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(80)
            $0.height.equalTo(4)
        }
        
        cameraIcon.snp.makeConstraints{
            $0.top.equalTo(grabberIcon.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(24)
            $0.width.height.equalTo(28)
        }
        
        title.snp.makeConstraints{
            $0.top.equalTo(cameraIcon.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(24)
        }
        
        subTitle.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(24)
        }
        
        cameraBtn.snp.makeConstraints{
            $0.top.equalTo(subTitle.snp.bottom).offset(42)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }
        
        galleryBtn.snp.makeConstraints{
            $0.top.equalTo(cameraBtn.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }
    }
    
}
