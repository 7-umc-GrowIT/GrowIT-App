//
//  GrayBoxView.swift
//  GrowIT
//
//  Created by 오현민 on 7/27/25.
//

import UIKit

class GrayBoxView: UIView {
    // MARK: - Properties
    private lazy var grayText: String = ""
    private lazy var blackText: String = ""
    
    //MARK: - Components
    private lazy var grayLabel = AppLabel(
        text: grayText,
        font: .body2SemiBold(),
        textColor: .gray600
    )
    
    private lazy var blackLabel = AppLabel(
        text: blackText,
        font: .heading3SemiBold(),
        textColor: .gray900
    )
    
    private lazy var creditIcon = UIImageView().then {
        $0.image = UIImage(named: "GrowIT_Credit")
        $0.contentMode = .scaleAspectFill
    }

    // MARK: - init
    init(grayText: String, blackText: String) {
        super.init(frame: .zero)
        self.grayText = grayText
        self.blackText = blackText
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SetUI
    private func setUI() {
        self.backgroundColor = .gray50
        self.layer.cornerRadius = 16
        
        addSubviews([grayLabel, blackLabel, creditIcon])
        
        grayLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.centerX.equalToSuperview()
        }
        
        blackLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.centerX.equalToSuperview()
        }
        
        creditIcon.snp.makeConstraints {
            $0.trailing.equalTo(blackLabel.snp.leading).offset(12)
            $0.centerX.equalToSuperview()
        }
    }

    func setTexts(gray: String, black: String) {
        grayLabel.text = gray
        blackLabel.text = black
    }
    func setCreditIconVisible(_ visible: Bool) {
        creditIcon.isHidden = !visible
    }
}
