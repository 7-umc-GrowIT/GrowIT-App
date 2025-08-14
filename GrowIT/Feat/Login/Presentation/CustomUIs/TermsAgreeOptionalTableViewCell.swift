//
//  TermsAgreeTableViewCell.swift
//  GrowIT
//
//  Created by 이수현 on 1/26/25.
//

import UIKit

class TermsAgreeOptionalTableViewCell: UITableViewCell {
    
    static let identifier = "TermsAgreeOptionalTableViewCell"
    
    var onAgreeButtonTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        selectionStyle = .none
        
        agreeButton.addTarget(self, action: #selector(didTapAgreeButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    let agreeButton = CircleCheckButton(isEnabled: false).then {
        $0.isUserInteractionEnabled = true
    }
    
    private let mandatoryView = MandatoryOptionalView(backgroundColor: .primary100, text: "선택", textColor: .primary700)
    
    let titleLabel = UILabel().then {
        let count = 1
        $0.text = "이용약관(\(count))"
        $0.font = .heading3SemiBold()
        $0.textColor = .gray800
    }
    
    let contentLabel = UILabel().then {
        $0.font = .body2Regular()
        $0.textColor = .gray600
        $0.numberOfLines = 0
    }
    
    let detailButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.backgroundColor = .clear
        $0.tintColor = .gray200
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(agreeButton)
        agreeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(mandatoryView)
        mandatoryView.snp.makeConstraints { make in
            make.leading.equalTo(agreeButton.snp.trailing).offset(12)
            make.width.equalTo(37)
            make.height.equalTo(22)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(mandatoryView.snp.trailing).offset(6)
            make.centerY.equalTo(mandatoryView)
        }
        
        contentView.addSubview(detailButton)
        detailButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(title: String, content: String, isAgreed: Bool) {
        titleLabel.text = title
        contentLabel.text = content
        agreeButton.setSelectedState(isAgreed)
    }
    
    @objc private func didTapAgreeButton() {
        onAgreeButtonTapped?() // 클로저 호출
    }
}
