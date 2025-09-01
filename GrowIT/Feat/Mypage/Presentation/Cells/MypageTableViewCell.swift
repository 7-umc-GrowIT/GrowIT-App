//
//  MypageTableViewCell.swift
//  GrowIT
//
//  Created by 오현민 on 6/29/25.
//

import UIKit

class MypageTableViewCell: UITableViewCell {
    static let identifier = "MypageTableViewCell"
    
    //MARK: - Components
    private lazy var mainLabel = AppLabel(text: "",
                                           font: .heading2SemiBold(),
                                           textColor: .gray900)
    
    private lazy var subStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .center
        $0.spacing = 4
        $0.addArrangedSubViews([subLabel, rightArrow])
    }
    
    private lazy var subLabel = AppLabel(text: "",
                                         font: .body2SemiBold(),
                                         textColor: .gray600)
    
    private lazy var rightArrow = UIImageView().then {
        $0.image = UIImage(named: "GrowIT_Arrow_R")
        $0.contentMode = .scaleAspectFill
    }
    
    //MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        setView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 컴포넌트 추가
    private func setView() {
        self.contentView.addSubviews([mainLabel, subStackView])
    }
    
    //MARK: - 레이아웃 설정
    private func setConstraints() {
        mainLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview()
        }
        
        subStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview()
        }
    }
    
    //MARK: - Configure
    func configure(mainText: String, subText: String, hasArrow: Bool = true) {
        mainLabel.text = mainText
        subLabel.text = subText
        
        // subText가 비어있으면 subLabel 숨김
        subLabel.isHidden = subText.isEmpty
        
        // 화살표 표시 여부
        rightArrow.isHidden = !hasArrow
    }
}
