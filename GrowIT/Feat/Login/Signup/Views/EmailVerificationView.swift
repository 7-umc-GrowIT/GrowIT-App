//
//  EmailVerificationView.swift
//  GrowIT
//
//  Created by 강희정 on 1/25/25.
//

import UIKit
import SnapKit
import Then

class EmailVerificationView: UIView {
    // MARK: - Components
    private lazy var progressStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.addArrangedSubViews([progress_one, progress_two])
    }
    
    private lazy var progress_one = UIImageView().then  {
        $0.image = UIImage(named: "num1active")
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.snp.makeConstraints { $0.size.equalTo(24) }
    }
    
    private lazy var progress_two = UIImageView().then {
        $0.image = UIImage(named: "num2default")
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.snp.makeConstraints { $0.size.equalTo(24) }
    }
    
    public lazy var infoIcon = UIButton().then {
        $0.setImage(UIImage(named: "Info"), for: .normal)
        $0.snp.makeConstraints { $0.size.equalTo(15) }
    }
    
    public lazy var tooltipView = LeftToolTipView().then {
        $0.isHidden = true
    }
    
    private lazy var mainLabel = UILabel().then {
        $0.text = "이메일 인증을 진행할게요"
        $0.textColor = .gray900
        $0.textAlignment = .left
        $0.font = UIFont.subHeading1()
    }
    
    public lazy var emailField = TextFieldWithButton(
        textfieldTitle: "이메일",
        placeholder: "이메일을 입력해 주세요",
        buttonTitle: "인증번호 발송"
    )
    
    public lazy var codeField = TextFieldWithButton(
        textfieldTitle: "인증번호",
        placeholder: "인증번호를 입력해 주세요",
        buttonTitle: "인증하기"
    ).then {
        $0.setTextFieldInteraction(enabled: false)
    }
    
    public lazy var nextButton = AppButton(
        title: "다음으로",
        titleColor: .white,
        isEnabled: false
    ).then {
        $0.setButtonState(
            isEnabled: false,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400)
    }
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SetUI
    private func addViews() {
        addSubviews([progressStackView, mainLabel, emailField, codeField, nextButton, tooltipView, infoIcon])
    }
    
    private func setConstraints() {
        progressStackView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).inset(32)
            $0.leading.equalToSuperview().inset(24)
        }
        
        mainLabel.snp.makeConstraints {
            $0.top.equalTo(progressStackView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().inset(24)
        }
        
        emailField.snp.makeConstraints {
            $0.top.equalTo(mainLabel.snp.bottom).offset(28)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        codeField.snp.makeConstraints {
            $0.top.equalTo(emailField.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        infoIcon.snp.makeConstraints {
            $0.centerY.equalTo(emailField.titleLabel)
            $0.leading.equalTo(emailField.snp.leading).offset(51)
        }
        
        tooltipView.snp.makeConstraints {
            $0.leading.equalTo(infoIcon.snp.trailing).offset(6)
            $0.centerY.equalTo(infoIcon.snp.centerY)
            $0.height.equalTo(33)
        }
        
    }
}
