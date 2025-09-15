//
//  AppTextField.swift
//  GrowIT
//
//  Created by 오현민 on 9/13/25.
//

import UIKit

class AppTextField: UIView {
    // MARK: - Properties
    private var isPassword: Bool
    private var isPasswordVisible = false
    private var currentState: BottomLabelState = .none
    
    // MARK: - Components
    lazy var titleLabel = AppLabel(text: "",
                                   font: .heading3Bold(),
                                   textColor: .gray900)
    
    lazy var textField = UITextField().then {
        $0.font = .body1Medium()
        $0.textAlignment = .left
        $0.backgroundColor = .white
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.isSecureTextEntry = isPassword
        
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = UIColor.border.cgColor
        $0.layer.borderWidth = 1
        
        $0.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 12.0, height: 0.0))
        $0.leftViewMode = .always
        $0.rightView = buttonStackView
        $0.rightViewMode = .whileEditing
    }
    
    lazy var eyeButton = UIButton().then {
        $0.tintColor = .gray200
        $0.setImage(UIImage(named: "eye=off")?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.setImage(UIImage(named: "eye=on")?.withRenderingMode(.alwaysTemplate), for: .selected)
        $0.isHidden = true
    }
    
    lazy var clearButton = UIButton().then {
        $0.setImage(UIImage(named: "State=Default"), for: .normal)
        $0.tintColor = .gray200
        $0.isHidden = true
    }
    lazy var spacer = UIView().then {
        $0.snp.makeConstraints { $0.width.equalTo(12) }
    }
    
    lazy var bottomLabel = AppLabel(text: "",
                                    font: .detail2Regular(),
                                    textColor: .gray400).then {
        $0.isHidden = true
    }
    
    private lazy var allStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        
    }
    
    private lazy var buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 6
    }
    
    // MARK: - Init
    init(isPasswordField: Bool = false) {
        self.isPassword = isPasswordField
        super.init(frame: .zero)
        addViews()
        setupConstraints()
        addTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functional
    private func addTargets() {
        textField.addTarget(self, action: #selector(handleEditingDidBegin), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(handleEditingChanged), for: .editingChanged)
        textField.addTarget(self, action: #selector(handleEditingDidEnd), for: .editingDidEnd)

        
        clearButton.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)
        eyeButton.addTarget(self, action: #selector(didTapEyeButton), for: .touchUpInside)
    }
    
    // MARK: - Setting Custom Method
    func setTitleLabel(_ text: String) {
        titleLabel.text = text
    }
    
    func setTitleFont(_ font: UIFont) {
        titleLabel.font = font
    }
    
    func setPlaceholder(_ text: String) {
        textField.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [.foregroundColor: UIColor.gray300]
        )
    }
    
    func setTitleLabelAfterSpacing(_ spacing: Int) {
        allStackView.setCustomSpacing(CGFloat(spacing), after: titleLabel)
    }
    
    func setTitleLabeloffset(_ offset: Int) {
        textField.snp.updateConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(offset)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(48)
        }
    }
    
    // MARK: - 상태관리
    enum BottomLabelState {
        case none
        case hint(String)
        case error(String)
        case success(String)
        case errorNotLabel
        case successNotLabel
    }
    
    func setState(_ state: BottomLabelState) {
        currentState = state
        switch state {
        case .none:
            applyDefaultStyle()
            hideBottomLabel()
            
        case .hint(let message):
            applyDefaultStyle()
            showBottomLabel(message: message, color: .gray400)
            
        case .error(let message):
            applyErrorStyle()
            showBottomLabel(message: message, color: .negative400)
            
        case .success(let message):
            applySuccessStyle()
            showBottomLabel(message: message, color: .positive400)
            
        case .errorNotLabel:
            applyErrorStyle()
            hideBottomLabel()
            
        case .successNotLabel:
            applySuccessStyle()
            hideBottomLabel()
        }
    }
    
    func setTextFieldInteraction(enabled: Bool) {
        textField.isUserInteractionEnabled = enabled
        clearButton.isHidden = !enabled
        if !enabled {
            clearButton.setImage(nil, for: .normal)
        } else {
            clearButton.setImage(UIImage(named: "State=Default"), for: .normal)
        }
    }
    
    // MARK: Style
    private func applyDefaultStyle() {
        titleLabel.textColor = .gray900
        textField.textColor = .gray900
        textField.layer.borderColor = UIColor.border.cgColor
        textField.backgroundColor = .white
        clearButton.setImage(UIImage(named: "State=Default"), for: .normal)
        eyeButton.tintColor = .gray200
    }
    
    private func applyErrorStyle() {
        titleLabel.textColor = .negative400
        textField.textColor = .negative400
        textField.layer.borderColor = UIColor.negative400.cgColor
        textField.backgroundColor = .negative50
        clearButton.setImage(UIImage(named: "State=Error"), for: .normal)
        eyeButton.tintColor = .negative100
    }
    
    private func applySuccessStyle() {
        titleLabel.textColor = .gray900
        textField.textColor = .positive400
        textField.layer.borderColor = UIColor.positive400.cgColor
        textField.backgroundColor = .positive50
        clearButton.setImage(UIImage(named: "State=Default"), for: .normal)
        if isPassword {
            eyeButton.tintColor = .positive100
        }
    }
    
    private func showBottomLabel(message: String, color: UIColor) {
        bottomLabel.text = message
        bottomLabel.textColor = color
        bottomLabel.isHidden = false
    }
    
    private func hideBottomLabel() {
        bottomLabel.isHidden = true
        bottomLabel.text = nil
    }
    
    // MARK: - TextField Event Handler
    @objc
    private func handleEditingDidBegin() {
        if case .error = currentState { return }
        if case .success = currentState { return }
        if case .errorNotLabel = currentState { return }
        if case .successNotLabel = currentState { return }
        
        textField.layer.borderColor = UIColor.primary500.cgColor
    }
    
    @objc
    private func handleEditingChanged() {
        let shouldHide = textField.text?.isEmpty ?? true
        clearButton.isHidden = shouldHide
        if isPassword {
            eyeButton.isHidden = shouldHide
            eyeButton.isEnabled = !shouldHide
        }
        
    }
    
    @objc
    private func handleEditingDidEnd() {
        clearButton.isHidden = true
        clearButton.isEnabled = false
        
        if isPassword {
            eyeButton.isHidden = true
            eyeButton.isEnabled = false
        }

        switch currentState {
        case .error:
            textField.layer.borderColor = UIColor.negative400.cgColor
        case .success:
            textField.layer.borderColor = UIColor.positive400.cgColor
        default:
            textField.layer.borderColor = UIColor.border.cgColor
        }
    }


    
    // MARK: - Button Event Handler
    @objc
    private func didTapClearButton() {
        textField.text = ""
        setState(.none)
        textField.sendActions(for: .editingChanged)
    }
    
    @objc
    private func didTapEyeButton() {
        isPasswordVisible.toggle()
        textField.isSecureTextEntry = !isPasswordVisible
        eyeButton.isSelected = isPasswordVisible
        textField.sendActions(for: .editingChanged)
    }
    
    // MARK: - Setup UI
    private func addViews() {
        self.addSubview(allStackView)
        
        buttonStackView.addArrangedSubViews([eyeButton, clearButton, spacer])
        allStackView.addArrangedSubViews([titleLabel, textField, bottomLabel])
        allStackView.setCustomSpacing(8, after: titleLabel)
        allStackView.setCustomSpacing(4, after: textField)
    }
    
    private func setupConstraints() {
        allStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        textField.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        bottomLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.height.greaterThanOrEqualTo(16)
        }
        
        eyeButton.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        
        clearButton.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        
    }
}
