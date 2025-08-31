//
//  WithdrawModalView.swift
//  GrowIT
//
//  Created by 오현민 on 7/16/25.
//

import UIKit

class WithdrawModalView: UIView {
    // MARK: - Components
    private let titleLabel = AppLabel(
        text: "정말로 탈퇴할까요?",
        font: .heading2Bold(),
        textColor: .gray900)
    
    private let descLabel = AppLabel(
        text: "탈퇴하면 그로우잇 내 모든 기록이 사라집니다\n또한 삭제한 데이터는 복구가 어렵습니다",
        font: .body1Regular(),
        textColor: .gray500
    ).then {
        $0.numberOfLines = 0
    }
    
    public let cancleButton = AppButton(title: "취소")
    
    public let withDrawButton = SmallTextButton(title: "탈퇴하기").then {
        $0.setUnderline(true)
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
    
    //MARK: - Setup UI
    private func configure() {
        self.layer.cornerRadius = 40
        self.cancleButton.backgroundColor = .negative400
        self.cancleButton.setTitleColor(.white, for: .normal)
    }
    
    private func setView() {
        self.addSubviews([titleLabel, descLabel, cancleButton, withDrawButton])
    }
    
    //MARK: - 레이아웃 설정
    private func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(52)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        descLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        cancleButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.top.equalTo(descLabel.snp.bottom).offset(40)
        }
        
        withDrawButton.snp.makeConstraints {
            $0.top.equalTo(cancleButton.snp.bottom).offset(15)
            $0.bottom.equalToSuperview().inset(50)
            $0.centerX.equalTo(cancleButton)
        }
    }
}
