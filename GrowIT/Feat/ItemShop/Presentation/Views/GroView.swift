//
//  GroSelectBackgroundView.swift
//  GrowIT
//
//  Created by 오현민 on 1/7/25.
//
// MARK: - 아이템샵 메인화면 & 그로 초기 배경설정 화면

import UIKit
import Then
import SnapKit

class GroView: UIView {
    var groImageViewTopConstraint: Constraint?
    
    var backgroundImageView = UIImageView().then {
        $0.image = UIImage(named: "GrowIT_Background_Star") /// 그로 디폴트 이미지
        $0.contentMode = .scaleAspectFill
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var groFrameView = UIView().then {
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    var groFaceImageView = UIImageView().then {
        $0.image = UIImage(named: "GrowIT_Gro") /// 그로 디폴트 이미지
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var groFlowerPotImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var groAccImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var groObjectImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var zoomButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = .clear
        config.image = UIImage(named: "GrowIT_ZoomOut")
        
        $0.configuration = config
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var eraseButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = .clear
        config.image = UIImage(named: "GrowIT_Erase")
        
        $0.configuration = config
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    var buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 8
    }
    
    public var purchaseButton = PurchaseButton(credit: 0).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
        setConstraints()
        setGroLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Gro
    private func setGroLayer() {
        groFlowerPotImageView.layer.zPosition = 0
        groFaceImageView.layer.zPosition = 1
        groAccImageView.layer.zPosition = 2
        groObjectImageView.layer.zPosition = 3
    }
    
    //MARK: - 컴포넌트 추가
    private func setView() {
        buttonStackView.addArrangedSubViews([zoomButton, eraseButton])
        self.addSubviews([backgroundImageView, groFrameView, buttonStackView, purchaseButton])
        
        groFrameView.addSubviews([
            groFaceImageView,
            groFlowerPotImageView,
            groAccImageView,
            groObjectImageView
        ])
    }
    
    //MARK: - 레이아웃 설정
    private func setConstraints() {
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        groFrameView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(1.3)
            $0.height.equalTo(groFrameView.snp.width)
            $0.centerX.equalToSuperview()
            self.groImageViewTopConstraint = $0.top.equalToSuperview().inset(68).constraint
        }
        
        [groFaceImageView, groFlowerPotImageView, groAccImageView, groObjectImageView].forEach {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        buttonStackView.snp.makeConstraints {
            $0.bottom.equalTo(purchaseButton.snp.top).offset(-24)
            $0.trailing.equalToSuperview().inset(24)
        }
        
        zoomButton.snp.makeConstraints {
            $0.width.height.equalTo(48)
        }
        
        eraseButton.snp.makeConstraints {
            $0.width.height.equalTo(48)
        }
        
        purchaseButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }
        
    }
}
