//
//  TermsDetailView.swift
//  GrowIT
//
//  Created by 강희정 on 2/18/25.
//

import UIKit

class TermsDetailView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI Components
    
    let contentTextView = UITextView().then {
        $0.font = .body2Regular()
        $0.textColor = .gray800
        $0.isEditable = false
        $0.isScrollEnabled = true
    }
    
    let agreeButton = AppButton(title: "동의하기", titleColor: .gray400).then {
        $0.backgroundColor = .gray100
    }
    
    // MARK: Setup UI
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(contentTextView)
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-80)
        }

        
        addSubview(agreeButton)
        agreeButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(60)
        }
    }
    
    func configure(content: String) {
        contentTextView.text = content
    }
}
