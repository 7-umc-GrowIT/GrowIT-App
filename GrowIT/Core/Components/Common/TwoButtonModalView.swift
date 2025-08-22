//
//  TwoButtonModalView.swift
//  GrowIT
//
//  Created by 오현민 on 7/15/25.
//

import UIKit

class TwoButtonModalView: UIView {
    // MARK: - Components
    private let titleLabel = AppLabel(
        text: "",
        font: .heading2Bold(),
        textColor: .gray900)
    
    private let descLabel = AppLabel(
        text: "",
        font: .body1Regular(),
        textColor: .gray500
    ).then {
        $0.numberOfLines = 0
    }
    
    public let mainButton = AppButton(title: "")
    public let subButton = AppButton(title: "")

    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 8
    }
    
    // MARK: - init
    init(
        title: String,
        desc: String,
        mainBtn: String,
        subBtn: String,
        mainBtnColor: UIColor = .black,
        subBtnColor: UIColor = .gray100,
        mainTextColor: UIColor = .white,
        subTextColor: UIColor = .gray400
    ) {
        super.init(frame: .zero)
        self.backgroundColor = .white
        
        // 텍스트 할당
        self.titleLabel.text = title
        self.descLabel.text = desc
        
        self.mainButton.setTitle(mainBtn, for: .normal)
        self.subButton.setTitle(subBtn, for: .normal)
        self.mainButton.setTitleColor(mainTextColor, for: .normal)
        self.subButton.setTitleColor(subTextColor, for: .normal)
        
        // 버튼 색상 설정
        self.mainButton.backgroundColor = mainBtnColor
        self.subButton.backgroundColor = subBtnColor

        setupUI()
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup UI
    private func configure() {
        self.layer.cornerRadius = 40
    }
    
    private func setupUI() {
        buttonStackView.addArrangedSubViews([subButton, mainButton])
        addSubviews([titleLabel, descLabel, buttonStackView])
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(52)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        descLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.top.equalTo(descLabel.snp.bottom).offset(40)
        }
    }
}
