//
//  VoiceDiaryFixView.swift
//  GrowIT
//
//  Created by 이수현 on 1/16/25.
//

import UIKit

class DiaryPostFixView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI Components
    private let diaryIcon = UIImageView().then {
        $0.image = UIImage(named: "diaryIcon")
        $0.backgroundColor = .clear
    }
    
    private let fixLabel = UILabel().then {
        $0.text = "2025년 1월 24일"
        $0.font = .heading2Bold()
        $0.textColor = .primary600
    }
    
    private let label1 = UILabel().then {
        $0.text = "작성된 일기"
        $0.font = .heading3Bold()
        $0.textColor = .gray900
    }
    
    let textView = UITextView().then {
        $0.font = .body1Medium()
        $0.textColor = .gray900
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.textContainer.lineFragmentPadding = 12
        $0.layer.borderColor = UIColor.border2.cgColor
        $0.layer.borderWidth = 1
        $0.setLineSpacing(spacing: 8, font: .body1Medium(), color: .gray900)
    }
    
    let cancelButton = AppButton(title: "나가기", titleColor: .gray400).then {
        $0.backgroundColor = .gray100
    }
    
    let fixButton = AppButton(title: "수정하기", titleColor: .gray400).then {
        $0.backgroundColor = .gray100
    }
    
    let deleteLabel = UILabel().then {
        $0.text = "삭제하기"
        $0.font = .body2Medium()
        $0.textColor = .gray400
        $0.isUserInteractionEnabled = true
    }
    
    // MARK: Setup UI
    private func setupUI() {
        backgroundColor = .white
        addSubview(diaryIcon)
        diaryIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(52)
        }
        
        addSubview(fixLabel)
        fixLabel.snp.makeConstraints { make in
            make.leading.equalTo(diaryIcon.snp.leading)
            make.top.equalTo(diaryIcon.snp.bottom).offset(8)
        }
        
        addSubview(label1)
        label1.snp.makeConstraints { make in
            make.leading.equalTo(fixLabel.snp.leading)
            make.top.equalTo(fixLabel.snp.bottom).offset(16)
        }
        
        addSubview(textView)
        textView.snp.makeConstraints { make in
            make.leading.equalTo(label1.snp.leading)
            make.top.equalTo(label1.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(200)
        }
        
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.leading.equalTo(textView.snp.leading)
            make.top.equalTo(textView.snp.bottom).offset(40)
            make.width.equalTo(88)
        }
        
        addSubview(fixButton)
        fixButton.snp.makeConstraints { make in
            make.leading.equalTo(cancelButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalTo(cancelButton.snp.top)
        }
        
        addSubview(deleteLabel)
        deleteLabel.snp.makeConstraints { make in
            make.top.equalTo(fixButton.snp.bottom).offset(15.5)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: Configure
    func configure(text: String, date: String) {
        textView.text = text
        fixLabel.text = date
    }
}
