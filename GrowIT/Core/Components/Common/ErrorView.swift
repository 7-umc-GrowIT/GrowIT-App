//
//  ErrorView.swift
//  GrowIT
//
//  Created by 이수현 on 1/13/25.
//

import UIKit
import Then
import SnapKit

class ErrorView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Components
    private let grabberIcon = UIImageView().then {
        $0.image = UIImage(named: "grabberIcon")
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var diaryIcon = UIImageView().then {
        $0.image = UIImage(named: "diaryIcon")
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var label1 = UILabel().then {
        $0.text = "나가면 기록된 일기와 챌린지가 사라져요"
        $0.font = .heading2Bold()
        $0.textColor = .gray900
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
    }
    
    private lazy var label2 = UILabel().then {
        let allText = "페이지를 이탈하면 현재 기록된 일기가 사라져요\n그래도 처음 화면으로 돌아갈까요?"
        $0.text = allText
        $0.font = .heading3SemiBold()
        $0.textColor = .gray600
        $0.numberOfLines = 0
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
        $0.setPartialTextStyle(text: allText, targetText: "처음 화면", color: .primary600, font: .heading3SemiBold())
    }
    
    let exitButton = AppButton(title: "나가기", titleColor: .gray400).then {
        $0.backgroundColor = .gray100
    }
    
    let continueButton = AppButton(title: "계속 선택하기", titleColor: .white).then {
        $0.backgroundColor = .black
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        layer.cornerRadius = 40
        backgroundColor = .white
        
        addSubview(grabberIcon)
        grabberIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.width.equalTo(80)
            $0.height.equalTo(4)
            $0.centerX.equalToSuperview()
            
        }
        addSubview(diaryIcon)
        diaryIcon.snp.makeConstraints {
            $0.top.equalTo(grabberIcon.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(24)
            $0.size.equalTo(28)
        }
        
        addSubview(label1)
        label1.snp.makeConstraints {
            $0.top.equalTo(diaryIcon.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        addSubview(label2)
        label2.snp.makeConstraints {
            $0.top.equalTo(label1.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        addSubview(exitButton)
        exitButton.snp.makeConstraints {
            $0.top.equalTo(label2.snp.bottom).offset(40)
            $0.leading.equalToSuperview().inset(24)
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.width.equalTo(88)
        }
        
        addSubview(continueButton)
        continueButton.snp.makeConstraints {
            $0.top.equalTo(label2.snp.bottom).offset(40)
            $0.leading.equalTo(exitButton.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    // MARK: Configure
    func configure(icon: String,
                   fisrtLabel: String, secondLabel: String,
                   firstColor: UIColor, secondColor: UIColor,
                   title1: String, title1Color1: UIColor, title1Background: UIColor,
                   title2: String, title1Color2: UIColor, title2Background: UIColor, targetText: String, viewColor: UIColor
    ) {
        diaryIcon.image = UIImage(named: icon)
        
        label1.text = fisrtLabel
        label1.textColor = firstColor
        label2.text = secondLabel
        label2.textColor = secondColor
        label2.setPartialTextStyle(text: secondLabel, targetText: targetText, color: .primary400, font: .heading3SemiBold())
        
        exitButton.setTitle(title1, for: .normal)
        exitButton.setTitleColor(title1Color1, for: .normal)
        exitButton.backgroundColor = title1Background
        
        continueButton.setTitle(title2, for: .normal)
        continueButton.setTitleColor(title1Color2, for: .normal)
        continueButton.backgroundColor = title2Background
        
        backgroundColor = viewColor
    }
}
