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
    
    public lazy var newPwdTextField = AppTextField(isPasswordField: true).then {
        $0.setTitleLabel("새로운 비밀번호")
        $0.setPlaceholder("새로운 비밀번호를 입력해 주세요")
        $0.setTextFieldInteraction(enabled: false)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public lazy var pwdCheckTextField = AppTextField(isPasswordField: true).then {
        $0.setTitleLabel("비밀번호 확인")
        $0.setPlaceholder("비밀번호를 한 번 더 입력해 주세요")
        $0.setTextFieldInteraction(enabled: false)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public lazy var changePwdButton = AppButton(
        title: "비밀번호 변경하기",
        titleColor: .white,
        isEnabled: false
    ).then {
        $0.setButtonState(
            isEnabled: false,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
    }

    
    // MARK: - add Function & Constraints
    
    private func addComponents() {
        [emailField, codeField, newPwdTextField,
         pwdCheckTextField, changePwdButton].forEach(self.addSubview)
    }
    
    private func constraints() {
        emailField.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).inset(32)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        codeField.snp.makeConstraints {
            $0.top.equalTo(emailField.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        newPwdTextField.snp.makeConstraints {
            $0.top.equalTo(codeField.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        pwdCheckTextField.snp.makeConstraints {
            $0.top.equalTo(newPwdTextField.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        changePwdButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-40)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }
    }
}
