//
//  TextDiaryView.swift
//  GrowIT
//
//  Created by 이수현 on 1/12/25.
//

import UIKit
import Then
import SnapKit

class TextDiaryView: UIView, UITextViewDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        diaryTextField.delegate = self
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    let scrollView = UIScrollView()
    
    let contentView = UIView()
    
    private let dateView = UIView().then {
        $0.backgroundColor = .gray50
    }
    
    private let dayLabel = UILabel().then {
        $0.text = "어떤 하루였는지 알려주세요"
        $0.font = .body2SemiBold()
        $0.textColor = .primary600
    }
    
    let dateLabel = UILabel().then {
        $0.text = "날짜를 선택해주세요"
        $0.font = .heading2Bold()
        $0.textColor = .gray900
        $0.isUserInteractionEnabled = false
    }
    
    private let dropDownButton = UIButton().then {
        $0.setImage(UIImage(named: "dropdownIcon"), for: .normal)
        $0.backgroundColor = .clear
        $0.tintColor = .gray500
        $0.isUserInteractionEnabled = false
    }
    
    let dropDownStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
        $0.distribution = .fill
    }
    
    private let placeholder: String = "일기 내용을 입력하세요"
    let diaryTextField = UITextView().then {
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        $0.font = UIFont.body1Medium()
        $0.textColor = .gray300
        $0.text = "일기 내용을 입력하세요"
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.border.cgColor
        $0.setLineSpacing(spacing: 8, font: .body1Medium(), color: .gray300)
    }
    
    private let helpLabel = UILabel().then {
        $0.text = "직접 작성하는 일기는 100자 이상 적어야 합니다"
        $0.font = .detail2Regular()
        $0.textColor = .gray500
    }
    
    let saveButton = AppButton(title: "내가 입력한 일기 저장하기").then {
        $0.setButtonState(isEnabled: true, enabledColor: .gray100, disabledColor: .black, enabledTitleColor: .gray400, disabledTitleColor: .white)
    }
    
    // MARK: - Setup TextView
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeholder
            textView.textColor = .gray300
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        checkButtonState()
    }
    
    func checkButtonState() {
        let isDateSelected = dateLabel.text != "날짜를 선택해 주세요"
        let trimmedText = diaryTextField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let isTextValid = !trimmedText.isEmpty && trimmedText != placeholder && trimmedText.count >= 100
        
        saveButton.setButtonState(
            isEnabled: isDateSelected && isTextValid,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        addSubview(saveButton)
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(saveButton.snp.top).offset(-16)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // 구성 요소 추가
        contentView.addSubviews([dateView, diaryTextField, helpLabel])
        dropDownStack.addArrangedSubViews([dateLabel, dropDownButton])
        dateView.addSubviews([dayLabel, dropDownStack])
        
        dateView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(109)
        }
        
        dayLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(32)
        }
        
        dropDownStack.snp.makeConstraints {
            $0.top.equalTo(dayLabel.snp.bottom).offset(8)
            $0.left.equalTo(dayLabel.snp.left)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        diaryTextField.snp.makeConstraints { make in
            make.top.equalTo(dateView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.height.equalTo(360)
        }
        
        helpLabel.snp.makeConstraints { make in
            make.top.equalTo(diaryTextField.snp.bottom).offset(4)
            make.leading.equalTo(diaryTextField.snp.leading)
            make.bottom.equalToSuperview().offset(-20) // 콘텐츠 하단 기준
        }
        
        saveButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(60)
        }
    }
    
    func updateDateLabel(_ date: String) {
        dateLabel.text = date.formattedDate()
        //checkButtonState()
    }
}
