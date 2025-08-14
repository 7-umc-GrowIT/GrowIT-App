//
//  GradientButton.swift
//  GrowIT
//
//  Created by 오현민 on 1/21/25.
//

import UIKit

class GradientButton: UIButton {
    private lazy var treeIcon = UIImageView().then {
        $0.image = UIImage(named: "GrowIT_Tree")?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .grayColor400
        $0.contentMode = .scaleAspectFill
        $0.snp.makeConstraints {
            $0.size.equalTo(28)
        }
    }
    
    private lazy var title = UILabel().then {
        $0.text = "그로우잇 시작하기!"
        $0.textColor = .grayColor400
        $0.font = UIFont.heading2Bold()
        $0.textAlignment = .center
    }
    
    private lazy var buttonContentView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 10
        $0.isUserInteractionEnabled = false
    }
    
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.clipsToBounds = true
        
        configure()
        configureGradientLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - configure Button
    private func configure() {
        self.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
        buttonContentView.addArrangedSubViews([treeIcon, title])
        addSubview(buttonContentView)
        buttonContentView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        isUserInteractionEnabled = true
    }
    
    private func configureGradientLayer() {
        gradientLayer.colors = [UIColor.grayColor100!.cgColor, UIColor.grayColor100!.cgColor]
        gradientLayer.cornerRadius = 16
        layer.insertSublayer(gradientLayer, at: 0) // 가장 뒤에 삽입
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    func setButtonState(isEnabled: Bool, enabledColors: [CGColor], disabledColors: [CGColor], enabledTitleColor: UIColor, disabledTitleColor: UIColor) {
        self.isEnabled = isEnabled
        gradientLayer.colors = isEnabled ? enabledColors : disabledColors
        title.textColor = isEnabled ? enabledTitleColor : disabledTitleColor
        treeIcon.tintColor = isEnabled ? enabledTitleColor : disabledTitleColor
    }
}
