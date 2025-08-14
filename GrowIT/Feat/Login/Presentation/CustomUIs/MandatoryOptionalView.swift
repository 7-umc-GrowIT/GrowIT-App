//
//  MandatoryOptionalView.swift
//  GrowIT
//
//  Created by 이수현 on 1/26/25.
//

import UIKit

class MandatoryOptionalView: UIView {

    let backColor: UIColor
    let text: String
    let textColor: UIColor
    
    init(backgroundColor: UIColor, text: String, textColor: UIColor) {
        self.backColor = backgroundColor
        self.text = text
        self.textColor = textColor
        
        super.init(frame: .zero)
        setupUI()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = .negative50
        $0.layer.cornerRadius = 4
    }
    
    
    private let label = UILabel().then {
        $0.text = "필수"
        $0.textColor = .negative400
        $0.font = .detail1Medium()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    func configure() {
        backgroundView.backgroundColor = backColor
        label.text = text
        label.textColor = textColor
    }
    
}
