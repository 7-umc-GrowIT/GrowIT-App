//
//  EmailLoginView1.swift
//  GrowIT
//
//  Created by 강희정 on 1/15/25.
//

import UIKit
import SnapKit
import Then

class EmailLoginView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        addComponents()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    
    public lazy var emailTextField = CustomTextField(frame: .zero, isPasswordField: false).then {
        $0.setTitleLabel("이메일")
        $0.setPlaceholder("이메일을 입력해 주세요")
        $0.setValidationRule { text in
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: text)
        }
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public lazy var pwdTextField = CustomTextField(frame: .zero, isPasswordField: true).then {
        $0.setTitleLabel("비밀번호")
        $0.setPlaceholder("비밀번호를 입력해 주세요")
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public lazy var emailSaveButton = UIButton().then {
        $0.setImage(UIImage(named: "notcheckedBox"), for: .normal) // 기본 지정 이미지
        $0.setImage(UIImage(named: "checkedBox"), for: .selected) // 선택된 체크 박스
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var emailSaveLabel = UILabel().then {
        $0.text = "이메일 저장"
        $0.textColor = .gray700
        $0.textAlignment = .left
        $0.font = UIFont.body2Medium()
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // AppButton을 인스턴스화
    public lazy var loginButton = AppButton(
        title: "로그인하기",
        titleColor: .gray400,
        isEnabled: true
    ).then {
        // 초기 상태 설정
        $0.setButtonState(isEnabled: true, enabledColor: .gray100, disabledColor: .black, enabledTitleColor: .gray100, disabledTitleColor: .black)
    }
    
    // 이메일 찾기 버튼
    public lazy var findEmailButton = UIButton().then {
        $0.setTitle("이메일 찾기", for: .normal)
        $0.setTitleColor(.gray400, for: .normal)
        $0.titleLabel?.font = UIFont.body2Medium()
    }
    
    // 비밀번호 변경 버튼
    public lazy var changePwdButton = UIButton().then {
        $0.setTitle("비밀번호 변경", for: .normal)
        $0.setTitleColor(.gray400, for: .normal)
        $0.titleLabel?.font = UIFont.body2Medium()
    }
    
    // 회원가입 버튼
    public lazy var singUpButton = UIButton().then {
        $0.setTitle("회원가입", for: .normal)
        $0.setTitleColor(.gray400, for: .normal)
        $0.titleLabel?.font = UIFont.body2Medium()
    }
    
    // 구분선 생성 함수
    private func createDivider() -> UIView {
        let divider = UIView().then {
            $0.backgroundColor = .gray200
        }
        return divider
    }
    
     // 구분선
    private lazy var divider1 = createDivider()
    private lazy var divider2 = createDivider()

    // 버튼 스택뷰
    private lazy var buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 12
        $0.addArrangedSubview(findEmailButton)
        $0.addArrangedSubview(divider1)
        $0.addArrangedSubview(changePwdButton)
        $0.addArrangedSubview(divider2)
        $0.addArrangedSubview(singUpButton)
    }
    
    // MARK: - add Function & Constraints
    
    private func addComponents() {
        [emailTextField, pwdTextField,
         emailSaveButton, emailSaveLabel,
         loginButton, buttonStackView]
            .forEach(self.addSubview)
    }
    
    private func constraints() {
        emailTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(148)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(78)
        }
        
        pwdTextField.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(24)
            $0.leading.equalTo(emailTextField.snp.leading)
            $0.trailing.equalTo(emailTextField.snp.trailing)
            $0.height.equalTo(78)
        }
        
        emailSaveButton.snp.makeConstraints {
            $0.top.equalTo(pwdTextField.snp.bottom).offset(16.5)
            $0.leading.equalTo(pwdTextField.snp.leading)
            $0.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        emailSaveLabel.snp.makeConstraints {
            $0.centerY.equalTo(emailSaveButton)
            $0.leading.equalToSuperview().offset(48)
        }
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(pwdTextField.snp.bottom).offset(77)
            $0.leading.equalTo(pwdTextField.snp.leading)
            $0.trailing.equalTo(pwdTextField.snp.trailing)
            $0.height.equalTo(60)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(36)
        }
        
        divider1.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.height.equalTo(12)
        }
        
        divider2.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.height.equalTo(12)
        }
    }
}

