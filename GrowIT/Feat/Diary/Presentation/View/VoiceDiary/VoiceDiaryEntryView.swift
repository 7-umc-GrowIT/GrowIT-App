//
//  VoiceDiaryEntryView.swift
//  GrowIT
//
//  Created by 이수현 on 1/16/25.
//

import UIKit
import Lottie

class VoiceDiaryEntryView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        startAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 그라데이션 적용
        recordButton.setGradient(color1: .primary400, color2: .primary600)
    }
    
    private func startAnimation() {
        postImage.play()
    }
    
    // MARK: UI Components
    private let label1 = UILabel().then {
        $0.text = "편하게 말해 보세요\n당신의 이야기를 듣고 있어요"
        $0.font = .subTitle1()
        $0.textColor = .white
        $0.numberOfLines = 0
    }
    
    private let label2 = UILabel().then {
        $0.text = "버튼을 누르면 바로 통화가 시작돼요"
        $0.font = .heading3SemiBold()
        $0.textColor = .white
    }
    
    var postImage = LottieAnimationView(name: "Diary").then {
        $0.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        $0.loopMode = .loop
    }
    
    let recordButton = AppButton(title: " 오늘의 일기 기록하기", titleColor: .white, icon: "whiteDiary")
    
    private let tooltipView = ToolTipView().then {
        $0.configure(text: "처음이라면 크레딧 100 증정!")
    }
    
    let helpLabel = UILabel().then {
        $0.text = "일기 기록하는 법 알아보기"
        $0.font = .body2Medium()
        $0.textColor = .gray400
        $0.isUserInteractionEnabled = true
    }
    
    // MARK: Setup UI
    private func setupUI() {
        backgroundColor = .gray800
        addSubview(label1)
        label1.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalTo(safeAreaLayoutGuide).offset(32)
        }
        
        addSubview(label2)
        label2.snp.makeConstraints { make in
            make.leading.equalTo(label1.snp.leading)
            make.top.equalTo(label1.snp.bottom).offset(12)
        }
        
        addSubview(postImage)
        postImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(label2.snp.bottom).offset(30)
        }
        
        addSubview(recordButton)
        recordButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-84)
        }
        
        addSubview(tooltipView)
        tooltipView.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.centerX.equalTo(recordButton.snp.centerX)
            make.bottom.equalTo(recordButton.snp.top).offset(-6)
        }
        
        addSubview(helpLabel)
        helpLabel.snp.makeConstraints { make in
            // make.leading.equalTo(recordButton.snp.leading).offset(102)
            make.centerX.equalTo(recordButton.snp.centerX)
            make.top.equalTo(recordButton.snp.bottom).offset(8)
        }
    }
    
    
}
