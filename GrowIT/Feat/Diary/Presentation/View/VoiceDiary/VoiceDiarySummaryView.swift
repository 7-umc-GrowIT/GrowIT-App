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
        self.setGradient(color1: .gray700, color2: .gray900)
        
        // 그라데이션 적용
        setGradient(color1: .gray700, color2: .gray900)
    }
    
    // MARK: UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    private let label1 = UILabel().then {
        $0.text = "당신의 이야기를\n일기로 정리했어요"
        $0.font = .subTitle1()
        $0.textColor = .white
        $0.numberOfLines = 0
    }
    
    private let emoLabel = UILabel().then {
        $0.text = "오늘의 감정 키워드"
        $0.font = .body1Medium()
        $0.textColor = .gray100
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
        $0.backgroundColor = UIColor(hex: "#0B0B11", alpha: 0.5)
        $0.layer.cornerRadius = 20
    }
    
    private let dateLabel = UILabel().then {
        $0.text = ""
        $0.font = .heading3Bold()
        $0.textColor = .primary400
    }
    
    let diaryTextView = UITextView().then {
        $0.text = ""
        $0.textColor = .white
        $0.font = .body1Medium()
        $0.isEditable = false
        $0.backgroundColor = .clear
        $0.setLineSpacing(spacing: 12, font: .body1Medium(), color: .white)
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
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(label1)
        contentView.addSubview(emoLabel)
        contentView.addSubview(emoStackView)
        contentView.addSubview(todayDiaryLabel)
        contentView.addSubview(textView)
        
        textView.addSubview(dateLabel)
        textView.addSubview(diaryTextView)
        textView.addSubview(aiLabel)
        
        contentView.addSubview(saveButton)
        contentView.addSubview(descriptionLabel)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }

        label1.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(32)
        }
        
        emoLabel.snp.makeConstraints { make in
            make.leading.equalTo(label1.snp.leading)
            make.top.equalTo(label1.snp.bottom).offset(28)
        }
        
        emoStackView.snp.makeConstraints { make in
            make.leading.equalTo(emoLabel.snp.leading)
            make.top.equalTo(emoLabel.snp.bottom).offset(8)
        }
        
        todayDiaryLabel.snp.makeConstraints { make in
            make.leading.equalTo(emoStackView.snp.leading)
            make.top.equalTo(emoStackView.snp.bottom).offset(40)
        }
        
        textView.snp.makeConstraints { make in
            make.leading.equalTo(todayDiaryLabel.snp.leading)
            make.top.equalTo(todayDiaryLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(28)
            make.centerX.equalToSuperview()
        }
        
        diaryTextView.snp.makeConstraints { make in
            make.leading.equalTo(dateLabel.snp.leading)
            make.centerX.equalToSuperview()
            make.top.equalTo(dateLabel.snp.bottom).offset(12)
            make.height.equalTo(Constants.Screen.ScreenHeight * (216 / 932))
        }
        
        aiLabel.snp.makeConstraints { make in
            make.leading.equalTo(diaryTextView.snp.leading)
            make.top.equalTo(diaryTextView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-28)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(43)
            make.leading.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(saveButton.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-40) // 하단 여백 40pt
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
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ko_KR") // 한글 로케일
        outputFormatter.dateFormat = "yyyy년 M월 d일"
        
        if let dateObj = inputFormatter.date(from: date) {
            let formattedDate = outputFormatter.string(from: dateObj)
            dateLabel.text = formattedDate
        } else {
            dateLabel.text = date // 변환 실패 시 원본 보여주기
        }
    }
}
