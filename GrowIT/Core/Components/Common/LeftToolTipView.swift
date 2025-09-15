//
//  LeftToolTipView.swift
//  GrowIT
//
//  Created by 오현민 on 9/15/25.
//

import UIKit

class LeftToolTipView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Components
    private let rectView = UIView().then {
        $0.backgroundColor = UIColor(hex: "#00000099")
        $0.layer.cornerRadius = 8
    }
    
    private let textLabel = UILabel().then {
        $0.text = "메일이 없는 경우 스팸 메일함을 확인해 주세요"
        $0.font = .detail2Regular()
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private let tipView = TipView(direction: .left)
    
    // MARK: - Setup UI
    private func setupUI() {
        addSubview(rectView)
        rectView.snp.makeConstraints {
            $0.trailing.verticalEdges .equalToSuperview()
            $0.leading.equalToSuperview().inset(10)
        }
        
        rectView.addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.top.bottom.equalToSuperview().inset(8)
        }
        
        addSubview(tipView)
        tipView.snp.makeConstraints {
            $0.centerY.equalTo(rectView)
            $0.trailing.equalTo(rectView.snp.leading)
            $0.width.equalTo(8)
            $0.height.equalTo(12)
        }
    }
    
    // MARK: Configure
    func configure(text: String) {
        textLabel.text = text
    }
}
