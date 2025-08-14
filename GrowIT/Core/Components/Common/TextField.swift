//
//  TextField.swift
//  GrowIT
//
//  Created by 강희정 on 1/14/25.
//

import UIKit
import SnapKit

class CustomTextField: UIView {
    
    // MARK: - Properties
    let textField = UITextField()
    let titleLabel = UILabel()
    let errorLabel = UILabel()
    let clearButton = UIButton()
    let eyeButton = UIButton()
    
    private var isPasswordVisible = false
    private var showEyeButton: Bool // 눈 버튼을 표시할지 여부
    
    // 테두리
    let defaultBorderColor = UIColor.gray100.cgColor
    let activeBorderColor = UIColor.primary500.cgColor
    let errorBorderColor = UIColor.negative400.cgColor
    let successBorderColor = UIColor.positive400.cgColor
    
    // 배경
    let errorBackgroundColor = UIColor.negative50
    let defaultBackgroundColor = UIColor.white
    let successBackgroundColor = UIColor.positive50
    
    var validationRule: ((String) -> Bool)?
    var successCondition: (() -> Bool)? // 성공 조건 설정
    
    public var errorLabelTopConstraint: Constraint?
    
    // MARK: - Initializers
    init(frame: CGRect, isPasswordField: Bool = false) {
        self.showEyeButton = isPasswordField
        super.init(frame: frame)
        setupUI()
        addTargets()
    }
    
    required init?(coder: NSCoder) {
        self.showEyeButton = false // 기본값으로 초기화
        super.init(coder: coder)
        setupUI()
        addTargets()
    }
    
    
    // MARK: - Setup UI
    private func setupUI() {
        self.addSubview(titleLabel)
        self.addSubview(textField)
        self.addSubview(errorLabel)
        self.addSubview(clearButton)
        
        if showEyeButton {
            self.addSubview(eyeButton)
            eyeButton.isHidden = true
        }
        
        // Title Label 설정
        titleLabel.font = UIFont.heading3Bold()
        titleLabel.textColor = UIColor.black
        titleLabel.text = ""
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Text Field 설정
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.layer.borderColor = defaultBorderColor
        textField.backgroundColor = defaultBackgroundColor
        textField.isSecureTextEntry = showEyeButton
        textField.font = UIFont.body1Medium()
        textField.textAlignment = .left
        textField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 12.0, height: 0.0))
        textField.leftViewMode = .always
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        // Clear Button 설정
        clearButton.setImage(UIImage(named: "State=Default"), for: .normal)
        clearButton.isHidden = true
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        
        if showEyeButton {
            eyeButton.setImage(UIImage(named: "eye=off"), for: .normal)
            eyeButton.setImage(UIImage(named: "eye=on"), for: .selected)
            eyeButton.tintColor = .gray200
            eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        }
        
        // Error Label 설정
        errorLabel.font = UIFont.detail2Regular()
        errorLabel.textColor = UIColor.negative400
        errorLabel.text = ""
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        clearButton.snp.makeConstraints {
            $0.centerY.equalTo(textField)
            $0.trailing.equalTo(textField.snp.trailing).offset(-12)
            $0.height.equalTo(24)
        }
        
        if showEyeButton {
            eyeButton.snp.makeConstraints {
                $0.centerY.equalTo(textField)
                $0.trailing.equalTo(clearButton.snp.leading).offset(-6)
                $0.width.height.equalTo(24)
            }
        }
        
        errorLabel.snp.makeConstraints {
            errorLabelTopConstraint = $0.top.equalTo(textField.snp.bottom).offset(0).constraint
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
    }
    
    
    
    private func addTargets() {
        textField.addTarget(self, action: #selector(handleEditingDidBegin), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(handleEditingDidEnd), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(validateText), for: .editingChanged)
        textField.addTarget(self, action: #selector(toggleClearButtonVisibility), for: .editingChanged)
        textField.addTarget(self, action: #selector(toggleEyeButtonVisibility), for: .editingChanged)
    }
    
    
    
    // MARK: - Public Methods
    func setTitleLabel(_ text: String) {
        titleLabel.text = text
    }
    
    func setPlaceholder(_ text: String) {
        textField.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [.foregroundColor: UIColor.gray300]
        )
    }
    
    func setValidationRule(_ rule: @escaping (String) -> Bool) {
        self.validationRule = rule
    }
    
    func setSuccessConditiona(_ condition: @escaping () -> Bool) {
        self.successCondition = condition
    }
    
    func setError(message: String) {
        textField.layer.borderColor = errorBorderColor
        textField.backgroundColor = errorBackgroundColor
        errorLabel.text = message
        errorLabel.isHidden = false
        errorLabelTopConstraint?.update(offset: 4)
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
        
        titleLabel.textColor = UIColor.negative400
        clearButton.setImage(UIImage(named: "State=Error"), for: .normal)
        if showEyeButton {
            eyeButton.tintColor = .negative100
            eyeButton.isHidden = textField.text?.isEmpty ?? true
        }
        
    }
    
    func clearError() {
        textField.layer.borderColor = defaultBorderColor
        textField.backgroundColor = defaultBackgroundColor
        errorLabel.text = ""
        errorLabel.isHidden = true
        errorLabelTopConstraint?.update(offset: 0)
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
        
        titleLabel.textColor = UIColor.black
        clearButton.setImage(UIImage(named: "State=Default"), for: .normal)
    }
    
    func setSuccess() {
        textField.layer.borderColor = successBorderColor
        textField.backgroundColor = successBackgroundColor
        errorLabel.isHidden = true
        clearButton.isHidden = true
        if showEyeButton {
            eyeButton.tintColor = .positive100
            eyeButton.isHidden = textField.text?.isEmpty ?? true
        }
    }
    
    func clearSuccess() {
        textField.layer.borderColor = defaultBorderColor
        textField.backgroundColor = defaultBackgroundColor
    }
    
    // TextField 비활성화 시 clearButton 숨기기
    func setTextFieldInteraction(enabled: Bool) {
        textField.isUserInteractionEnabled = enabled
        clearButton.isHidden = !enabled
        if !enabled {
            clearButton.setImage(nil, for: .normal)
        } else {
            clearButton.setImage(UIImage(named: "State=Default"), for: .normal)
        }
    }
    
    // MARK: - Private Methods
    @objc private func handleEditingDidBegin() {
        textField.layer.borderColor = activeBorderColor
        titleLabel.textColor = UIColor.gray900
    }
    
    @objc private func handleEditingDidEnd() {
        validateText()
        checkSuccessCondition()
    }
    
    @objc private func validateText() {
        guard let text = textField.text, let validationRule = validationRule else { return }
        if validationRule(text) {
            clearError()
        } else {
            setError(message: "올바르지 않은 형식입니다")
        }
    }
    
    @objc private func checkSuccessCondition() {
        guard let successCondition = successCondition else { return }
        if successCondition() {
            setSuccess()
        } else {
            clearSuccess()
        }
    }
    
    @objc private func clearTextField() {
        textField.text = ""
        toggleClearButtonVisibility()
        clearError()
        clearSuccess()
        textField.sendActions(for: .editingChanged)
    }
    
    @objc private func toggleClearButtonVisibility() {
        clearButton.isHidden = textField.text?.isEmpty ?? true
    }
    
    @objc private func togglePasswordVisibility() {
        isPasswordVisible.toggle()
        textField.isSecureTextEntry = !isPasswordVisible
        eyeButton.isSelected = isPasswordVisible
    }
    
    @objc private func toggleEyeButtonVisibility() {
        if showEyeButton {
            eyeButton.isHidden = textField.text?.isEmpty ?? true
            
        }
    }
    
}
