//
//  VoiceDiaryFixView.swift
//  GrowIT
//
//  Created by 이수현 on 1/16/25.
//

import UIKit

class VoiceDiaryFixView: UIView {

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
        $0.text = "일기 내용을 수정할게요"
        $0.font = .heading2Bold()
        $0.textColor = .white
    }
    
    private let label1 = UILabel().then {
        $0.text = "작성된 일기"
        $0.font = .heading3Bold()
        $0.textColor = .gray300
    }
    
    let textView = UITextView().then {
        $0.font = .body1Medium()
        $0.textColor = .white
        $0.backgroundColor = .gray700
        $0.layer.cornerRadius = 8
        $0.textContainer.lineFragmentPadding = 12
        $0.setLineSpacing(spacing: 8, font: .body1Medium(), color: .white)
    }
    
    private let errorLabel = UILabel().then {
        $0.text = "감정 분석을 위해 100자 이내로 작성한 경우 수정이 불가합니다"
        $0.font = .detail2Regular()
        $0.textColor = .negative400
        $0.isHidden = true
    }
    
    let cancelButton = AppButton(title: "취소", titleColor: .gray400).then {
        $0.backgroundColor = .gray700
    }
    
    let fixButton = AppButton(title: "수정하기", titleColor: .gray400).then {
        $0.backgroundColor = .gray700
    }
    
    // MARK: Setup UI
    private func setupUI() {
        backgroundColor = .gray800
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
        
        addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.leading.equalTo(textView.snp.leading)
            make.top.equalTo(textView.snp.bottom).offset(4)
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
    }
    
    // MARK: Configure
    func configure(text: String) {
        textView.text = text
    }
    
    func lessThanHundred(isEnabled: Bool) {
        label1.textColor = isEnabled ? .negative400 : .gray300
        textView.textColor = isEnabled ? .negative400 : .white
        textView.layer.borderColor =  isEnabled ? UIColor.negative400.cgColor : UIColor.clear.cgColor
        textView.layer.borderWidth = isEnabled ? 1 : 0
        errorLabel.isHidden = !isEnabled
    }

}
