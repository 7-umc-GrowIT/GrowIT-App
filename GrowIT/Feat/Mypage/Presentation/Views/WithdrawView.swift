//
//  WithdrawView.swift
//  GrowIT
//
//  Created by 오현민 on 8/29/25.
//

import UIKit

class WithdrawView: UIView {
    //MARK: - Data
    //MARK: - Components
    private lazy var mainLabel = AppLabel(
        text: "샤샤 님, 탈퇴하신다니 아쉬워요",
        font: .heading1Bold(),
        textColor: .gray900
    )
    
    private lazy var descLabel = AppLabel(
        text: "탈퇴하면 지금까지 진행한 챌린지와 구매한 아이템이 사라져요.\n또한 삭제한 데이터는 복구가 어렵습니다.",
        font: .body2Medium(),
        textColor: .gray500
    ).then {
        $0.numberOfLines = 0
    }
    
    private lazy var reasonLabel = AppLabel(
        text: "탈퇴 이유",
        font: .heading3Bold(),
        textColor: .gray900
    )
    
    public let dropDownView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        $0.layer.borderWidth = 1
    }
    
    public lazy var dropDownLabel = AppLabel(
        text: "탈퇴 이유를 선택해 주세요",
        font: .body1Medium(),
        textColor: .gray300
    )
    
    private lazy var dropdownIcon = UIImageView().then {
        $0.image = UIImage(named: "GrowIT_Dropdown")
        $0.contentMode = .scaleAspectFill
    }
    
    public let dropdownTableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = true
        $0.isScrollEnabled = true
        
        $0.backgroundColor = .gray50
        $0.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 8
        $0.isHidden = true
    }
    
    private let bottomGrayView = UIView().then {
        $0.backgroundColor = .gray50
    }
    
    private lazy var bottomTitleLabel = AppLabel(
        text: "탈퇴 시 안내",
        font: .body2SemiBold(),
        textColor: .gray500
    )
    
    private lazy var subLabel = AppLabel(
        text: """
        • 회원 탈퇴 시 작성된 일기 및 캐릭터 정보는 즉시 삭제되며, 복구가 불가능합니다.\n
        • 일부 데이터(결제 이력 등)는 관련 법령에 따라 일정 기간 보관 후 자동 삭제됩니다.\n
        • 탈퇴 사유는 통계 및 서비스 개선 목적으로 수집되며, 익명 처리됩니다.\n
        • 탈퇴 이후에도 재가입은 언제든지 가능합니다.
        """,
        font: .detail2Regular(),
        textColor: .gray500
    ).then {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.headIndent = 8
        
        
        let attrString = NSMutableAttributedString(
            string: $0.text ?? "",
            attributes: [
                .font: UIFont.detail2Regular(),
                .foregroundColor: UIColor.gray500,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        $0.numberOfLines = 0
        $0.attributedText = attrString
    }
    
    public let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 8
        $0.isHidden = true
    }
    
    public let withdrawButton = AppButton(title: "탈퇴하기").then {
        $0.backgroundColor = .black
        $0.setTitleColor(.white, for: .normal)
    }
    
    public let cancleButton = AppButton(title: "취소").then {
        $0.backgroundColor = .gray100
        $0.setTitleColor(.gray400, for: .normal)
    }
    
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setView()
        setConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - SetUI
    private func setView() {
        addSubviews([mainLabel, descLabel, reasonLabel, dropDownView, dropdownTableView, bottomGrayView, buttonStackView])
        
        dropDownView.addSubviews([dropDownLabel, dropdownIcon])
        bottomGrayView.addSubviews([bottomTitleLabel, subLabel])
        buttonStackView.addArrangedSubViews([cancleButton, withdrawButton])
    }
    
    private func setConstraints() {
        mainLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.top.equalTo(safeAreaLayoutGuide).inset(32)
        }
        
        descLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.top.equalTo(mainLabel.snp.bottom).offset(4)
        }
        
        reasonLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(28)
            $0.top.equalTo(descLabel.snp.bottom).offset(52)
        }
        
        dropDownView.snp.makeConstraints {
            $0.top.equalTo(reasonLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(28)
            $0.height.equalTo(48)
        }
        
        dropDownLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
        
        dropdownIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        dropdownTableView.snp.makeConstraints {
            $0.top.equalTo(dropDownView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(28)
            $0.height.equalTo(192)
        }
        
        bottomGrayView.snp.makeConstraints {
            $0.height.equalTo(312)
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        bottomTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.top.equalToSuperview().inset(32)
        }
        
        subLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(27)
            $0.top.equalTo(bottomTitleLabel.snp.bottom).offset(8)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}
