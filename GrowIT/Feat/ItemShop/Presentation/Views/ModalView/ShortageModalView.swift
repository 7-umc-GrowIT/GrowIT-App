//
//  ShortageModalView.swift
//  GrowIT
//
//  Created by 오현민 on 1/26/25.
//

import Foundation
import UIKit

class ShortageModalView: UIView {
    private lazy var cartIcon = UIImageView().then {
        $0.image = UIImage(named: "GrowIT_Cart_Red")
        $0.contentMode = .scaleAspectFill
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.text = "크레딧이 부족해요"
        $0.font = UIFont.heading2Bold()
        $0.textColor = UIColor.grayColor900
        $0.textAlignment = .left
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var subtitleLabel = UILabel().then {
        $0.text = "일기나 챌린지를 통해 크레딧을 모아보세요!"
        $0.font = UIFont.heading3SemiBold()
        $0.textColor = UIColor.grayColor700
        $0.textAlignment = .left
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var confirmButton = UIButton().then {
        $0.setTitle("확인했어요", for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.titleLabel?.font = UIFont.heading2Bold()
        
        $0.backgroundColor = .negative400
        $0.layer.cornerRadius = 16
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
        self.addSubviews([cartIcon, titleLabel, subtitleLabel, confirmButton])
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
        
        confirmButton.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }
    }
    
}

