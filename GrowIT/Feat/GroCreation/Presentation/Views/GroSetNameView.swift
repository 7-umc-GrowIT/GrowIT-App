//  GroSetNameView.swift
//  GrowIT
//
//  Created by 오현민 on 1/7/25.
//

import UIKit

class GroSetNameView: UIView {
    private var gradientColors: [CGColor]
    private var iconImage: UIImage
    
    private lazy var shapeIcon = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var subtitleLabel = UILabel().then {
        $0.text = "마지막 단계예요"
        $0.font = UIFont.body1Medium()
        $0.textColor = UIColor.grayColor500
        $0.textAlignment = .left
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.text = "당신의 그로 이름을 알려 주세요"
        $0.font = UIFont.subHeading2()
        $0.textColor = UIColor.grayColor900
        $0.textAlignment = .left
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var nickNameTextField = CustomTextField(frame: .zero, isPasswordField: false).then {
        $0.setTitleLabel("닉네임")
        $0.setPlaceholder("닉네임을 입력해주세요")
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var groImageView = UIImageView().then {
        $0.image = UIImage(named: "GrowIT_Gro")
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = false
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var nextButton = GradientButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //MARK: - init
    init(gradientColors: [CGColor], iconImage: UIImage) {
        self.gradientColors = gradientColors
        self.iconImage = iconImage
        super.init(frame: .zero)
        self.backgroundColor = .white
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure View
    private func configureView() {
        setView()
        setConstraints()
        configureGradientLayer()
        configureIconImage()
    }
    
    private func configureGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = gradientColors
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func configureIconImage() {
        shapeIcon.image = iconImage
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.sublayers?.forEach { layer in
            if let gradientLayer = layer as? CAGradientLayer {
                gradientLayer.frame = self.bounds
            }
        }
    }
    
    //MARK: - 컴포넌트 추가
    private func setView() {
        addSubviews([
            shapeIcon, subtitleLabel, titleLabel, nickNameTextField, groImageView, nextButton
        ])
    }
    
    //MARK: - 레이아웃 설정
    private func setConstraints() {
        shapeIcon.snp.makeConstraints {
            $0.width.height.equalTo(32)
            $0.top.equalTo(safeAreaLayoutGuide).inset(60)
            $0.leading.equalToSuperview().inset(24)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(shapeIcon.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom)
            $0.leading.equalToSuperview().inset(24)
        }
        
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.height.equalTo(80)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        groImageView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(194)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(1.3)
            $0.height.equalTo(groImageView.snp.width)
        }
        
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }
    }
}
