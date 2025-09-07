//
//  AccountInquiryModalView.swift
//  GrowIT
//
//  Created by 허준호 on 9/7/25.
//

import UIKit
import SnapKit
import Then

class AccountInquiryModalView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let grabberIcon = UIImageView().then {
        $0.image = UIImage(named: "grabberIcon")
        $0.contentMode = .scaleAspectFit
    }
    
    let mainIcon = UIImageView().then {
        $0.image = UIImage(named: "accountInquiry")
        $0.contentMode = .scaleAspectFit
    }
    
    let title = UILabel().then {
        $0.text = "계정 문의는 아래 이메일로 부탁드려요"
        $0.font = .heading2Bold()
        $0.textColor = .gray900
        $0.adjustsFontSizeToFitWidth = true
    }
    
    let subTitle = UILabel().then {
        $0.text = "growIT2025@gmail.com\n이메일에 이름을 입력해서 보내주세요"
        $0.textColor = .gray600
        $0.font = .heading3SemiBold()
        $0.numberOfLines = 0
        $0.adjustsFontSizeToFitWidth = true
    }
    
    let confirmBtn = UIButton().then {
        $0.setTitle("확인했어요", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .heading2Bold()
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 16
    }
    
    private func setUpView() {
        self.addSubviews([grabberIcon, mainIcon, title, subTitle, confirmBtn])
        
        grabberIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(80)
            $0.height.equalTo(4)
        }
        
        mainIcon.snp.makeConstraints {
            $0.top.equalTo(grabberIcon.snp.bottom).offset(24)
            $0.left.equalTo(24)
            $0.width.height.equalTo(28)
        }
        
        title.snp.makeConstraints {
            $0.top.equalTo(mainIcon.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        subTitle.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        confirmBtn.snp.makeConstraints {
            $0.top.equalTo(subTitle.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(60)
        }
    }
}
