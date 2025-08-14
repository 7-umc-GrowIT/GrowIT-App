//
//  TermsAgreeView.swift
//  GrowIT
//
//  Created by 이수현 on 1/26/25.
//

import UIKit
import SnapKit
import Then

class TermsAgreeView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addComponents()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI Components
    private lazy var scrollView = UIScrollView(frame: self.bounds).then{
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    private let topLabel = UILabel().then {
        let allText = "그로우잇 시작을 위한\n필수 약관에 동의해 주세요"
        $0.text = allText
        $0.font = .subHeading1()
        $0.textColor = .gray900
        $0.numberOfLines = 0
        $0.setPartialTextStyle(text: allText, targetText: "그로우잇", color: .primary500, font: .subHeading1())
    }
    
    private let allAgreeView = UIView().then {
        $0.backgroundColor = .gray50
        $0.layer.cornerRadius = 8
    }
    
    let checkButton = CircleCheckButton(isEnabled: false)
    
    private let allAgreeLabel = UILabel().then {
        $0.text = "약관 모두 동의하기"
        $0.font = .heading3SemiBold()
        $0.textColor = .gray800
    }
    
    private let termsLabel = UILabel().then {
        $0.text = "그로우잇 이용약관"
        $0.font = .detail1Medium()
        $0.textColor = .gray400
    }
    
    let termsTableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.register(TermsAgreeTableViewCell.self, forCellReuseIdentifier: TermsAgreeTableViewCell.identifier)
        $0.tag = 0
    }
    
    private let termsLabel2 = UILabel().then {
        $0.text = "그로우잇 이용약관"
        $0.font = .detail1Medium()
        $0.textColor = .gray400
    }
    
    let termsOptTableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.register(TermsAgreeOptionalTableViewCell.self, forCellReuseIdentifier: TermsAgreeOptionalTableViewCell.identifier)
        $0.tag = 1
    }
    
    let nextButton = AppButton(title: "다음으로", titleColor: .gray400).then {
        $0.backgroundColor = .gray100
    }
    
    private func addComponents(){
        self.addSubview(scrollView)
        //scrollView.addSubview(contentView)
        [topLabel, allAgreeView, termsLabel, termsTableView, termsLabel2, termsOptTableView, nextButton].forEach(scrollView.addSubview)
        [checkButton, allAgreeLabel].forEach(allAgreeView.addSubview)
    }
    
    // MARK: Setup UI
    private func setupUI() {
        backgroundColor = .white
        
        scrollView.snp.makeConstraints{
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        topLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(32)
        }
        
        allAgreeView.snp.makeConstraints { make in
            make.leading.equalTo(topLabel.snp.leading)
            make.centerX.equalToSuperview()
            make.top.equalTo(topLabel.snp.bottom).offset(28)
            make.height.equalTo(60)
        }
        
        checkButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        allAgreeLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkButton.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }
        
        termsLabel.snp.makeConstraints { make in
            make.leading.equalTo(allAgreeView.snp.leading)
            make.top.equalTo(allAgreeView.snp.bottom).offset(16)
        }
        
        termsTableView.snp.makeConstraints { make in
            make.top.equalTo(termsLabel.snp.bottom).offset(4)
            make.leading.equalTo(termsLabel.snp.leading)
            make.centerX.equalToSuperview()
            make.height.equalTo(240)
        }
        
        termsLabel2.snp.makeConstraints { make in
            make.leading.equalTo(termsTableView.snp.leading)
            make.top.equalTo(termsTableView.snp.bottom).offset(24)
        }
        
        termsOptTableView.snp.makeConstraints { make in
            make.leading.equalTo(termsLabel2.snp.leading)
            make.top.equalTo(termsLabel2.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.height.equalTo(120)
        }
    
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(termsOptTableView.snp.leading)
            make.top.equalTo(termsOptTableView.snp.bottom).offset(80)
            make.bottom.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
    }
    
}
