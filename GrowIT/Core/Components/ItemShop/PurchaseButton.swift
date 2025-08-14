//
//  PurchaseButton.swift
//  GrowIT
//
//  Created by 오현민 on 1/8/25.
//

import Foundation
import UIKit
import SnapKit

class PurchaseButton: UIButton {
    // MARK: - Properties
    private lazy var credit: Int = 0
    
    // MARK: - UI Components
    private lazy var creditIcon = UIImageView().then {
        $0.image = UIImage(named: "GrowIT_Credit_Glow")
        $0.contentMode = .scaleAspectFill
        $0.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 23, height: 24))
        }
    }
    
    private lazy var creditLabel = UILabel().then {
        $0.text = String(credit)
        $0.textColor = UIColor.primaryColor400!
        $0.font = UIFont.heading2Bold()
        $0.textAlignment = .center
    }
    
    private lazy var purchaseLabel = UILabel().then {
        $0.text = "구매하기"
        $0.textColor = .white
        $0.font = UIFont.heading2Bold()
        $0.textAlignment = .center
    }
    
    private lazy var buttonContentView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 5
    }
    
    // MARK: - init
    init(credit: Int) {
        super.init(frame: .zero)
        self.credit = credit
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    private func configure() {
        buttonContentView.addArrangedSubViews([creditIcon, creditLabel, purchaseLabel])
        buttonContentView.setCustomSpacing(10, after: creditLabel)
        addSubview(buttonContentView)
        
        buttonContentView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .black
        self.configuration = config
        
        layer.cornerRadius = 16
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        // 버튼 터치인식 설정
        isUserInteractionEnabled = true
        [buttonContentView, creditIcon, creditLabel, purchaseLabel].forEach {
            $0.isUserInteractionEnabled = false
        }
    }
    
    // MARK: - UI Update
    func updateCredit(_ credit: Int) {
        creditLabel.text = String(credit)
    }
}
