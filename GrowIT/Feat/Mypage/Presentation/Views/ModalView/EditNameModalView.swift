//
//  EditNameModalView.swift
//  GrowIT
//
//  Created by 오현민 on 7/12/25.
//

import UIKit

class EditNameModalView: UIView {
    //MARK: - Components
    private let grabberIcon = UIImageView().then {
        $0.image = UIImage(named: "grabberIcon")
        $0.contentMode = .scaleAspectFit
    }
    
    public lazy var nickNameTextField = AppTextField(isPasswordField: false).then {
        $0.setTitleLabel("변경할 닉네임을 입력해 주세요")
        $0.setPlaceholder("닉네임을 입력해 주세요")
        $0.setTitleFont(UIFont.heading2Bold())
        $0.setTitleLabeloffset(16)
        $0.setState(.hint("2~8자 이내의 닉네임을 작성해 주세요"))
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public lazy var changeButton = AppButton(title: "닉네임 변경하기").then {
        $0.setButtonState(
            isEnabled: false,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
    }
    
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        configure()
        setView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup UI
    private func configure() {
        self.layer.cornerRadius = 40
    }
    
    private func setView() {
        self.addSubviews([grabberIcon, nickNameTextField, changeButton])
    }
    
    //MARK: - 레이아웃 설정
    private func setConstraints() {
        grabberIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.width.equalTo(80)
            $0.height.equalTo(4)
            $0.centerX.equalToSuperview()
        }
        
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(grabberIcon.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(100)
        }
        
        changeButton.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(24)

        }
    }
}
