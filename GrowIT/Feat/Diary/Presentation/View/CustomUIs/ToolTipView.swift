//
//  ToolTipView.swift
//  GrowIT
//
//  Created by 이수현 on 1/14/25.
//

import UIKit

class ToolTipView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Components
    private let circleView = UIView().then {
        $0.backgroundColor = UIColor(hex: "#00000099")
        $0.layer.cornerRadius = 16
    }
    
    private let textLabel = UILabel().then {
        $0.text = "눌러서 설명 카드를 볼 수 있어요"
        $0.font = .body2Medium()
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private let tipView = TipView()
    
    // MARK: - Setup UI
    private func setupUI() {
        addSubview(circleView)
        circleView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
        }
        circleView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        addSubview(tipView)
        tipView.snp.makeConstraints { make in
            make.top.equalTo(circleView.snp.bottom)
            make.width.equalTo(16)
            make.height.equalTo(10)
            make.centerX.equalTo(circleView)
        }
    
    }
    
    // MARK: Configure
    func configure(text: String) {
        textLabel.text = text
    }
}
