//
//  VoiceDiarySummaryView.swift
//  GrowIT
//
//  Created by 이수현 on 1/16/25.
//

import UIKit

class VoiceDiarySummaryView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 그라데이션 적용
        setGradient(color1: .gray700, color2: .gray900)
    }
    
    // MARK: UI Components
    private let label1 = UILabel().then {
        $0.text = "당신의 이야기를\n일기로 정리했어요"
        $0.font = .subTitle1()
        $0.textColor = .white
        $0.numberOfLines = 0
    }
    
    private let emoLabel = UILabel().then {
        $0.text = "오늘의 감정 키워드"
        $0.font = .body1Medium()
        $0.textColor = .gray500
    }
    
    private let emoStackView = EmoStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .equalSpacing
        $0.backgroundColor = .clear
        $0.configure(rectColor: UIColor(hex: "00B277")!.withAlphaComponent(0.2), titleColor: .primary200)
    }
    
    private let todayDiaryLabel = UILabel().then {
        $0.text = "오늘의 일기"
        $0.font = .body1Medium()
        $0.textColor = .gray100
    }
    
    private let textView = UIView().then {
        $0.backgroundColor = UIColor(hex: "#800b0b11")
        $0.layer.cornerRadius = 20
    }
    
    private let dateLabel = UILabel().then {
        $0.text = "2024년 12월 15일"
        $0.font = .heading3Bold()
        $0.textColor = .primary400
    }
    
    let diaryLabel = UILabel().then {
        $0.text = "오늘은 평소보다 조금 더 차분한 하루를 보냈다. 아침에 일어나 창밖을 보니 햇살이 눈부시게 비치고 있었다. 차가운 겨울 공기 속에서도 따뜻한 햇살이 포근하게 느껴졌다. 오후에는 간단히 산책을 나갔다. 겨울 특유의 청량한 공기를 마시며 걷다 보니, 머릿속이 맑아지고 새로운 아이디어도 떠올랐다. 저녁에는 따뜻한 차 한 잔과 함께 하루를 정리하며 감사한 마음으로 마무리했다."
        $0.font = .body1Medium()
        $0.textColor = .white
        $0.numberOfLines = 0
    }
    
    let diaryTextView = UITextView().then {
        $0.text = ""
        $0.textColor = .white
        $0.font = .body1Medium()
        $0.isEditable = false
        $0.backgroundColor = .clear
        $0.setLineSpacing(spacing: 8, font: .body1Medium(), color: .white)
    }
    
    private let aiLabel = UILabel().then {
        $0.text = "해당 내용은 AI가 정리한 내용입니다."
        $0.font = .detail1Medium()
        $0.textColor = .gray400
        $0.textAlignment = .right
    }
    
    let saveButton = AppButton(title: "AI가 입력해 준 일기 저장하기", titleColor: .black).then {
        $0.backgroundColor = .primary400
        
    }
    
    let descriptionLabel = UILabel().then {
        $0.text = "수정하고 싶은 내용이 있어요"
        $0.font = .body2Medium()
        $0.textColor = .gray400
        $0.isUserInteractionEnabled = true
    }
    
    // MARK: Setup UI
    private func setupUI() {
        addSubview(label1)
        label1.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalTo(safeAreaLayoutGuide).offset(32)
        }
        
        addSubview(emoLabel)
        emoLabel.snp.makeConstraints { make in
            make.leading.equalTo(label1.snp.leading)
            make.top.equalTo(label1.snp.bottom).offset(28)
        }
        
        addSubview(emoStackView)
        emoStackView.snp.makeConstraints { make in
            make.leading.equalTo(emoLabel.snp.leading)
            make.top.equalTo(emoLabel.snp.bottom).offset(8)
        }
        
        addSubview(todayDiaryLabel)
        todayDiaryLabel.snp.makeConstraints { make in
            make.leading.equalTo(emoStackView.snp.leading)
            make.top.equalTo(emoStackView.snp.bottom).offset(40)
        }
        
        addSubview(textView)
        textView.snp.makeConstraints { make in
            make.leading.equalTo(todayDiaryLabel.snp.leading)
            make.top.equalTo(todayDiaryLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        textView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(28)
            make.centerX.equalToSuperview()
        }
        
        textView.addSubview(diaryTextView)
        diaryTextView.snp.makeConstraints { make in
            make.leading.equalTo(dateLabel.snp.leading)
            make.centerX.equalToSuperview()
            make.top.equalTo(dateLabel.snp.bottom).offset(12)
            make.height.equalTo(Constants.Screen.ScreenHeight * (216 / 932))
        }
        
        textView.addSubview(aiLabel)
        aiLabel.snp.makeConstraints { make in
            make.leading.equalTo(diaryTextView.snp.leading)
            make.top.equalTo(diaryTextView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-28)
        }
        
        addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(43)
            make.leading.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
        }
        
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(saveButton.snp.bottom).offset(8)
        }
    }
    
    func configure(text: String) {
        diaryTextView.text = text
    }

    func updateEmo(emotionKeywords: [EmotionKeyword]) {
        let keywords = emotionKeywords.prefix(3).map { $0.keyword }
        emoStackView.updateLabels(with: keywords)
    }
    
    func updateDate(with date: String) {
        dateLabel.text = date
    }
    
}
