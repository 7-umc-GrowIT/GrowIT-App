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
        // setTodayDate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    
    private let dateView = UIView().then {
        $0.backgroundColor = .gray50
    }
    
    private let dayLabel = UILabel().then {
        $0.text = "어떤 하루였는지 알려주세요"
        $0.font = .body2SemiBold()
        $0.textColor = .primary600
    }
    
    let dateLabel = UILabel().then {
        $0.text = "날짜를 선택해 주세요"
        $0.font = .heading2Bold()
        $0.textColor = .gray900
    }
    
    let dropDownButton = UIButton().then {
        $0.setImage(UIImage(named: "dropdownIcon"), for: .normal)
        $0.backgroundColor = .clear
        $0.tintColor = .gray500
    }
    
    private let placeholder: String = "일기 내용을 입력하세요"
    let diaryTextField = UITextView().then {
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        $0.font = UIFont.body1Medium()
        $0.textColor = .gray300
        $0.text = "일기 내용을 입력하세요"
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        $0.setLineSpacing(spacing: 8, font: .body1Medium(), color: .gray300)
    }
    
    private let helpLabel = UILabel().then {
        $0.text = "직접 작성하는 일기는 100자 이상 적어야 합니다"
        $0.font = .detail2Regular()
        $0.textColor = .gray500
    }
    
    let saveButton = AppButton(title: "내가 입력한 일기 저장하기").then {
        $0.setButtonState(isEnabled: false, enabledColor: .black, disabledColor: .gray100, enabledTitleColor: .white, disabledTitleColor: .gray400)
        $0.isUserInteractionEnabled = false
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
    
    private func checkButtonState() {
        let isDateSelected = dateLabel.text != "날짜를 선택해 주세요"
        let isTextValid = !diaryTextField.text.isEmpty && diaryTextField.text != placeholder && diaryTextField.text.count > 100
        
        saveButton.setButtonState(
            isEnabled: isDateSelected && isTextValid,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
        
        if isDateSelected && isTextValid {
            saveButton.isUserInteractionEnabled = true
        } else {
            saveButton.isUserInteractionEnabled = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        addSubview(dateView)
        dateView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(109)
        }
        
        dateView.addSubview(dayLabel)
        dayLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(32)
        }
        
        dateView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(dayLabel)
            make.top.equalTo(dayLabel.snp.bottom).offset(8)
            // make.width.equalTo(160)
        }
        
        addSubview(dropDownButton)
        dropDownButton.snp.makeConstraints { make in
            make.leading.equalTo(dateLabel.snp.trailing).offset(4)
            make.centerY.equalTo(dateLabel.snp.centerY)
        }
        
        addSubview(diaryTextField)
        diaryTextField.snp.makeConstraints { make in
            make.top.equalTo(dateView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.height.equalTo(360)
        }
        
        addSubview(helpLabel)
        helpLabel.snp.makeConstraints { make in
            make.top.equalTo(diaryTextField.snp.bottom).offset(4)
            make.leading.equalTo(diaryTextField.snp.leading)
        }
        
        addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.leading.equalTo(diaryTextField)
            make.centerX.equalTo(diaryTextField)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
//    private func setTodayDate() {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy년 M월 d일"
//        formatter.locale = Locale(identifier: "ko_KR")
//        
//        dateLabel.text = formatter.string(from: Date())
//    }
    
    func updateDateLabel(_ date: String) {
        dateLabel.text = date.formattedDate()
        checkButtonState()
    }
}
