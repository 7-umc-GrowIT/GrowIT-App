//
//  TextFieldWithButton.swift
//  GrowIT
//
//  Created by 오현민 on 9/14/25.
//

import UIKit

class TextFieldWithButton: UIView {
    // MARK: - Properties
    private var textfieldTitle: String
    private var placeholder: String
    private var buttonTitle: String
    private var isEnabled: Bool = false
    
    // MARK: - Components
    public lazy var textField = AppTextField(isPasswordField: false).then {
        $0.setTitleLabel(textfieldTitle)
        $0.setPlaceholder(placeholder)
    }
    
    public lazy var button = UIButton().then {
        var titleColor: UIColor = isEnabled ? .white : .gray400
        var backgroundColor: UIColor = isEnabled ? .black : .gray100
        
        $0.setTitle(buttonTitle, for: .normal)
        $0.setTitleColor(titleColor, for: .normal)
        $0.backgroundColor = backgroundColor
        $0.titleLabel?.font = UIFont.body1Medium()
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.border.cgColor
    }
    
    // MARK: - Init
    init(textfieldTitle: String, placeholder: String, buttonTitle: String) {
        self.textfieldTitle = textfieldTitle
        self.placeholder = placeholder
        self.buttonTitle = buttonTitle
        super.init(frame: .zero)
        
        addViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Interface (VC에서 쓰기 쉽게 추가)
    var text: String? {
        return textField.textField.text
    }
    
    var textColor: UIColor? {
        get { return textField.textField.textColor }
        set { textField.textField.textColor = newValue }
    }
    
    func setState(_ state: AppTextField.BottomLabelState) {
        textField.setState(state)
    }
    
    func setTextFieldInteraction(enabled: Bool) {
        textField.setTextFieldInteraction(enabled: enabled)
    }
    
    var actionButton: UIButton {
        return button
    }
    
    var innerTextField: UITextField {
        return textField.textField
    }
    
    var titleLabel: UILabel {
        return textField.titleLabel
    }
    
    // MARK: - Functional
    func setButtonState(isEnabled: Bool) {
        // isEnabled 값에 따라 배경색을 다르게 설정
        let titleColor: UIColor = isEnabled ? .white : .gray400
        let backgroundColor: UIColor = isEnabled ? .black : .gray100
        
        button.backgroundColor = backgroundColor
        button.setTitleColor(titleColor, for: .normal)
        button.isEnabled = isEnabled
    }
    
    // MARK: - Setup UI
    private func addViews() {
        self.addSubviews([textField, button])
    }
    
    private func setupConstraints() {
        textField.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.trailing.equalTo(button.snp.leading).offset(-8)
        }
        
        button.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(textField.textField.snp.centerY)
            $0.height.equalTo(48)
            $0.width.equalTo(108)
        }
    }
}
