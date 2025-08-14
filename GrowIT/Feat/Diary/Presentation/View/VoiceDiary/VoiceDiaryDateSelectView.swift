//
//  VoiceDiaryDateSelectView.swift
//  GrowIT
//
//  Created by 이수현 on 1/16/25.
//

import UIKit

class VoiceDiaryDateSelectView: UIView {

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
        $0.text = "일기를 기록하는\n날짜를 선택해 주세요"
        $0.font = .subTitle1()
        $0.textColor = .white
        $0.numberOfLines = 0
    }
    
    let dateLabel = UILabel().then {
        $0.text = "일기 날짜"
        $0.font = .heading3Bold()
        $0.textColor = .gray300
    }
    
    let dateView = UIView().then {
        $0.backgroundColor = .gray700
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.clear.cgColor
    }
    
    let dateSelectLabel = UILabel().then {
        $0.text = "일기 날짜를 선택해 주세요"
        $0.font = .body1Medium()
        $0.textColor = .gray500
    }
    
    let toggleButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        $0.backgroundColor = .clear
        $0.tintColor = .gray500
        $0.isUserInteractionEnabled = false
    }
    
    let warningLabel = UILabel().then {
        $0.text = "일기 날짜는 필수로 선택해야 합니다"
        $0.textColor = .negative400
        $0.font = .detail2Regular()
        $0.isHidden = true
    }
    
    let startButton = AppButton(title: "대화 시작하기", titleColor: .black).then {
        $0.backgroundColor = .primary400
    }
    
    let helpLabel = UILabel().then {
        $0.text = "일기 기록하는 법 알아보기"
        $0.font = .body2Medium()
        $0.textColor = .gray400
        $0.isUserInteractionEnabled = true
    }
    
    // MARK: Setup UI
    private func setupUI() {
        addSubview(label1)
        label1.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(32)
            make.leading.equalToSuperview().offset(24)
        }
        
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(label1.snp.leading)
            make.top.equalTo(label1.snp.bottom).offset(40)
        }
        
        addSubview(dateView)
        dateView.snp.makeConstraints { make in
            make.leading.equalTo(dateLabel.snp.leading)
            make.centerX.equalToSuperview()
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.height.equalTo(48)
        }
        
        dateView.addSubview(dateSelectLabel)
        dateSelectLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        dateView.addSubview(toggleButton)
        toggleButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        
        addSubview(warningLabel)
        warningLabel.snp.makeConstraints { make in
            make.top.equalTo(dateView.snp.bottom).offset(4)
            make.leading.equalTo(dateView.snp.leading)
        }
        
        addSubview(startButton)
        startButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-84)
        }
        
        addSubview(helpLabel)
        helpLabel.snp.makeConstraints { make in
            make.top.equalTo(startButton.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: UI Update
    func updateDateLabel(_ date: String) {
        dateSelectLabel.text = date.formattedDate()
        dateSelectLabel.textColor = .white
    }

}
