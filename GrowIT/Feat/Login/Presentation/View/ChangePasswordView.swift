//
//  ChangePasswordView.swift
//  GrowIT
//
//  Created by 강희정 on 1/17/25.
//

import UIKit
import SnapKit
import Then

class ChangePasswordView: UIView {
    
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
    
    public lazy var emailTextField = CustomTextField(frame: .zero, isPasswordField: false).then {
        $0.setTitleLabel("이메일")
        $0.setPlaceholder("이메일을 입력해 주세요")
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public lazy var emailLabel = UILabel().then {
        $0.text = "가입 시 사용했던 이메일을 입력해 주세요"
        $0.textColor = .gray500
        $0.textAlignment = .left
        $0.font = UIFont.detail2Regular()
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public lazy var sendCodeButton = AppButton(
        title: "인증번호 발송",
        titleColor: .gray400,
        isEnabled: true
    ).then {
        // 초기 상태 설정
        $0.setButtonState(isEnabled: true, enabledColor: .gray100, disabledColor: .black, enabledTitleColor: .gray100, disabledTitleColor: .black)
        
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
        $0.setButtonState(isEnabled: true, enabledColor: .gray100, disabledColor: .black, enabledTitleColor: .gray100, disabledTitleColor: .black)
        
        $0.titleLabel?.font = UIFont.body1Medium()
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray300.cgColor
    }
    
    public lazy var newPwdTextField = CustomTextField(frame: .zero, isPasswordField: true).then {
        $0.setTitleLabel("새로운 비밀번호")
        $0.setPlaceholder("새로운 비밀번호를 입력해 주세요")
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public lazy var pwdCheckTextField = CustomTextField(frame: .zero, isPasswordField: true).then {
        $0.setTitleLabel("비밀번호 확인")
        $0.setPlaceholder("비밀번호를 한 번 더 입력해 주세요")
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // AppButton을 인스턴스화
    public lazy var changePwdButton = AppButton(
        title: "비밀번호 변경하기",
        titleColor: .white, // 활성화 상태에서의 텍스트 색상
        isEnabled: false    // 기본 비활성화 상태
    ).then {
        $0.setButtonState(
            isEnabled: false,
            enabledColor: .black,         // 활성화 상태의 배경색
            disabledColor: .gray100,      // 비활성화 상태의 배경색
            enabledTitleColor: .white,    // 활성화 상태의 텍스트 색상
            disabledTitleColor: .gray400  // 비활성화 상태의 텍스트 색상
        )
    }

    
    // MARK: - add Function & Constraints
    
    private func addComponents() {
        [emailTextField, emailLabel, sendCodeButton,
         codeTextField, certificationButton, newPwdTextField,
         pwdCheckTextField, changePwdButton]
            .forEach(self.addSubview)
    }
    
    private func constraints() {
        emailTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(148)
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(78)
        }
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(4)
            $0.leading.equalTo(emailTextField)
        }
        
        sendCodeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(178)
            $0.leading.equalTo(emailTextField.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-24)
            $0.width.equalTo(108)
            $0.height.equalTo(48)
        }
        
        codeTextField.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(45)
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
        
        newPwdTextField.snp.makeConstraints {
            $0.top.equalTo(codeTextField.snp.bottom).offset(24)
            $0.leading.equalTo(codeTextField)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(78)
        }
        
        pwdCheckTextField.snp.makeConstraints {
            $0.top.equalTo(newPwdTextField.snp.bottom).offset(24)
            $0.leading.equalTo(codeTextField)
            $0.trailing.equalTo(newPwdTextField)
            $0.height.equalTo(78)
        }
        
        changePwdButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-40)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(60)
        }
    }
}

