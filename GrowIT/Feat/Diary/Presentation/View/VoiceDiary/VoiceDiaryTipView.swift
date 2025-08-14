//
//  VoiceDiaryTipView.swift
//  GrowIT
//
//  Created by 이수현 on 1/18/25.
//

import UIKit

class VoiceDiaryTipView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Components
    private lazy var diaryIcon = UIImageView().then {
        $0.image = UIImage(named: "bulbIcon")
        $0.backgroundColor = .clear
    }
    
    private lazy var label1 = UILabel().then {
        $0.text = "그로우잇 일기 작성 Tip"
        $0.font = .heading2Bold()
        $0.textColor = .white
    }
    
    private lazy var label2 = UILabel().then {
        $0.text = "오늘 느낀 감정을 솔직하게 작성해 주세요!\n구체적인 챌린지 추천이 가능합니다"
        $0.font = .heading3SemiBold()
        $0.textColor = .gray300
        $0.numberOfLines = 0
    }
    
    let exitButton = AppButton(title: "확인했어요", titleColor: .black).then {
        $0.backgroundColor = .primary400
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .gray700
        addSubview(diaryIcon)
        diaryIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(52)
        }
        
        addSubview(label1)
        label1.snp.makeConstraints { make in
            make.leading.equalTo(diaryIcon.snp.leading)
            make.top.equalTo(diaryIcon.snp.bottom).offset(8)
        }
        
        addSubview(label2)
        label2.snp.makeConstraints { make in
            make.leading.equalTo(label1.snp.leading)
            make.top.equalTo(label1.snp.bottom).offset(16)
        }
        
        addSubview(exitButton)
        exitButton.snp.makeConstraints { make in
            make.leading.equalTo(label2.snp.leading)
            make.top.equalTo(label2.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: Configure
    func configure(icon: String,
                   fisrtLabel: String, secondLabel: String,
                   title1: String, title1Color1: UIColor, title1Background: UIColor,
                   title2: String, title1Color2: UIColor, title2Background: UIColor
    ) {
        diaryIcon.image = UIImage(named: icon)
        
        label1.text = fisrtLabel
        label2.text = secondLabel
        
        exitButton.titleLabel?.textColor = title1Color1
        exitButton.backgroundColor = title1Background
    }

}
