//
//  VoiceDiaryLoadingView.swift
//  GrowIT
//
//  Created by 이수현 on 1/16/25.
//

import UIKit
import Lottie

class VoiceDiaryLoadingView: UIView {

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
    
    // MARK: - UI Components
    private let recommendLabel = UILabel().then {
        $0.text = "AI가 나의 이야기를\n일기로 정리하고 있어요"
        $0.textColor = .white
        $0.numberOfLines = 0
        $0.font = .subTitle1()
    }
    
    private let waitLabel = UILabel().then {
        $0.text = "조금만 기다려 주세요"
        $0.textColor = .gray100
        $0.font = .heading3SemiBold()
    }
    
    var loadingIndicator = LottieAnimationView(name: "Loading").then {
        $0.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        addSubview(recommendLabel)
        recommendLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(148)
        }
        
        addSubview(waitLabel)
        waitLabel.snp.makeConstraints { make in
            make.leading.equalTo(recommendLabel.snp.leading)
            make.top.equalTo(recommendLabel.snp.bottom).offset(12)
        }
        
        addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(waitLabel.snp.bottom).offset(20)
        }
        loadingIndicator.loopMode = .loop
        loadingIndicator.play()
    }

}
