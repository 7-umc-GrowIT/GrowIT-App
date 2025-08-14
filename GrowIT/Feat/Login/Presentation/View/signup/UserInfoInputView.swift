//
//  UserInfoInputView.swift
//  GrowIT
//
//  Created by 강희정 on 1/25/25.
//

import UIKit
import SnapKit
import Then

class UserInfoInputView: UIView {

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
    
    public lazy var num1View = UIImageView().then {
        $0.image = UIImage(named: "num1default")
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public lazy var num2View = UIImageView().then {
        $0.image = UIImage(named: "num2active")
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public lazy var mainLabel = UILabel().then {
        $0.text = "이름과 비밀번호를 입력해 주세요"
        $0.textColor = .gray900
        $0.textAlignment = .left
        $0.font = UIFont.subHeading1()
    }
    
    public lazy var nameTextField = CustomTextField(frame: .zero, isPasswordField: false).then {
        $0.setTitleLabel("이름")
        $0.setPlaceholder("이름을 입력해 주세요")
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public lazy var passwordTextField = CustomTextField(frame: .zero, isPasswordField: true).then {
        $0.setTitleLabel("비밀번호")
        $0.setPlaceholder("비밀번호를 입력해 주세요")
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public lazy var passwordCheckTextField = CustomTextField(frame: .zero, isPasswordField: true).then {
        $0.setTitleLabel("비밀번호 확인")
        $0.setPlaceholder("비밀번호를 한 번 더 입력해 주세요")
    }
    
    public lazy var nextButton = AppButton(
        title: "다음으로",
        titleColor: .white,
        isEnabled: false
    ).then {
        $0.setButtonState(
            isEnabled: false, enabledColor: .black, disabledColor: .gray100,
            enabledTitleColor: .white, disabledTitleColor: .gray400)
        
    }
    
    // MARK: - Constraints
    
    private func addComponents() {
        [num1View, num2View, mainLabel,
         nameTextField, passwordTextField, passwordCheckTextField,
         nextButton]
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
        
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(mainLabel.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(78)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(78)
        }
        
        passwordCheckTextField.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(78)
        }
        
        nextButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-40)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }
    }
}
