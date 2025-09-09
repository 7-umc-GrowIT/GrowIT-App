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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        addComponents()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:)has not been implemented")
    }
    
    // MARK: - UI Components
    
    public lazy var num1View = UIImageView().then  {
        $0.image = UIImage(named: "num1active")
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public lazy var num2View = UIImageView().then {
        $0.image = UIImage(named: "num2default")
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public lazy var mainLabel = UILabel().then {
        $0.text = "이메일 인증을 진행할게요"
        $0.textColor = .gray900
        $0.textAlignment = .left
        $0.font = UIFont.subHeading1()
    }
    
    public lazy var emailTextField = CustomTextField(frame: .zero, isPasswordField: false).then {
        $0.setTitleLabel("이메일")
        $0.setPlaceholder("이메일을 입력해 주세요")
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public lazy var sendCodeButton = AppButton(
        title: "인증번호 발송",
        titleColor: .gray400,
        isEnabled: true
    ).then {
        // 초기 상태 설정
        $0.setButtonState(
            isEnabled: false, enabledColor: .black, disabledColor: .gray100, enabledTitleColor: .white, disabledTitleColor: .gray400)
        
        $0.titleLabel?.font = UIFont.body1Medium()
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray300.cgColor
    }
    
    public lazy var codeTextField = CustomTextField(frame: .zero, isPasswordField: false).then {
        $0.setTitleLabel("인증번호")
        $0.setPlaceholder("인증번호를 입력해 주세요")
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    public lazy var certificationButton = AppButton(
        title: "인증하기",
        titleColor: .gray400,
        isEnabled: true
    ).then {
        // 초기 상태 설정
        $0.setButtonState(
            isEnabled: false, enabledColor: .black, disabledColor: .gray100, enabledTitleColor: .white, disabledTitleColor: .gray400)
        
        $0.titleLabel?.font = UIFont.body1Medium()
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray300.cgColor
    }
    
    
    public lazy var nextButton = AppButton(
        title: "다음으로",
        titleColor: .white,
        isEnabled: false
    ).then {
        $0.setButtonState(
            isEnabled: false, enabledColor: .black, disabledColor: .gray100, enabledTitleColor: .white, disabledTitleColor: .gray400)
    }
    
    // MARK: - Constraints
    
    private func addComponents() {
        [num1View, num2View, mainLabel,
         emailTextField, codeTextField,
         sendCodeButton, certificationButton, nextButton]
            .forEach(self.addSubview)
    }
    
    private func constraints() {
        num1View.snp.makeConstraints {
            $0.top.equalToSuperview().offset(148)
            $0.leading.equalToSuperview().offset(24)
            $0.width.height.equalTo(24)
        }
        
        num2View.snp.makeConstraints {
            $0.centerY.equalTo(num1View)
            $0.leading.equalTo(num1View.snp.trailing).offset(12)
            $0.width.height.equalTo(24)
        }
        
        mainLabel.snp.makeConstraints {
            $0.top.equalTo(num1View.snp.bottom).offset(12)
            $0.leading.equalTo(num1View)
        }
        
        emailTextField.snp.makeConstraints {
            $0.top.equalTo(mainLabel.snp.bottom).offset(28)
            $0.leading.equalTo(mainLabel)
            $0.height.equalTo(78)
        }
        
        sendCodeButton.snp.makeConstraints {
            $0.bottom.equalTo(emailTextField.snp.bottom)
            $0.leading.equalTo(emailTextField.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-24)
            $0.width.equalTo(108)
            $0.height.equalTo(48)
        }
        
        codeTextField.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(24)
            $0.leading.equalTo(emailTextField)
            $0.height.equalTo(78)
        }
        
        certificationButton.snp.makeConstraints {
            $0.bottom.equalTo(codeTextField.snp.bottom)
            $0.leading.equalTo(codeTextField.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-24)
            $0.width.equalTo(108)
            $0.height.equalTo(48)
        }
        
        nextButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-40)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }
    }

}
