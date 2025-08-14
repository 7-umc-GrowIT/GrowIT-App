//
//  PurchaseModalView.swift
//  GrowIT
//
//  Created by 오현민 on 1/12/25.
//

import UIKit

class PurchaseModalView: UIView {
    
    private lazy var cartIcon = UIImageView().then {
        $0.image = UIImage(named: "GrowIT_Cart")
        $0.contentMode = .scaleAspectFill
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.text = "선택한 아이템 1개를 구입할게요"
        let targetString = "1개"
        
        $0.font = UIFont.heading2Bold()
        $0.textColor = UIColor.grayColor900
        $0.asColor(targetString: targetString, color: UIColor.primary600)
        $0.textAlignment = .left
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var subtitleLabel = UILabel().then {
        $0.text = "구매 후 바로 착용해 보세요!"
        $0.font = UIFont.heading3SemiBold()
        $0.textColor = UIColor.grayColor700
        $0.textAlignment = .left
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var cancleButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(UIColor.grayColor400, for: .normal)
        $0.titleLabel?.font = UIFont.heading2Bold()
        
        $0.backgroundColor = .grayColor100
        $0.layer.cornerRadius = 16
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var purchaseButton = PurchaseButton(credit: 0).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
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
    
    private func configure() {
        self.layer.cornerRadius = 40
    }
    
    //MARK: - 컴포넌트 추가
    private func setView() {
        self.addSubviews([cartIcon, titleLabel, subtitleLabel, cancleButton, purchaseButton])
    }
    
    //MARK: - 레이아웃 설정
    private func setConstraints() {
        cartIcon.snp.makeConstraints {
            $0.top.equalToSuperview().inset(52)
            $0.leading.equalToSuperview().inset(24)
            $0.width.height.equalTo(28)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(cartIcon.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(24)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(24)
        }
        
        cancleButton.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(40)
            $0.leading.equalToSuperview().inset(24)
            $0.width.equalTo(88).priority(.low)
            $0.height.equalTo(60)
        }
        
        purchaseButton.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(40)
            $0.leading.equalTo(cancleButton.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(24)
            $0.width.equalTo(286).priority(.low)
            $0.height.equalTo(60)
        }
    }
    
}
