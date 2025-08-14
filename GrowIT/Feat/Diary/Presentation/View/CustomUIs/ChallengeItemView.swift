//
//  ChallengeItemView.swift
//  GrowIT
//
//  Created by 이수현 on 2/17/25.
//

import Foundation
import UIKit
import SnapKit

class ChallengeItemView: UIView {
    
    private let containerView = UIView()
    private var isFlipped = false
    
    private let frontView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 20
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(hex: "#0000001A")?.cgColor
    }
    
    private let backView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 20
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(hex: "#0000001A")?.cgColor
        $0.isHidden = true
    }
    
    private let icon = UIImageView().then {
        $0.image = UIImage(named: "ChallengeIcon")
        $0.backgroundColor = .clear
    }
    
    private let label = UILabel().then {
        $0.text = ""
        $0.font = .heading3Bold()
        $0.textColor = .gray900
    }
    
    let button = CircleCheckButton(isEnabled: false)
    
    private let clockIcon = UIImageView().then {
        $0.image = UIImage(named: "clock")
        $0.backgroundColor = .clear
    }
    
    private let clockLabel = UILabel().then {
        $0.text = ""
        $0.font = .body2Medium()
        $0.textColor = .primary600
    }
    
    private let backIcon = UIImageView().then {
        $0.image = UIImage(named: "ChallengeIcon")
        $0.backgroundColor = .clear
    }
    
    private let backLabel = UILabel().then {
        $0.text = ""
        $0.font = .body2SemiBold()
        $0.textColor = .gray900
        $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.setGradient(color1: .white, color2: .primary50)
    }
    
    private func setupUI() {
        // containerView 안에 frontView, backView 추가
        containerView.addSubview(frontView)
        containerView.addSubview(backView)
        
        frontView.snp.makeConstraints { $0.edges.equalToSuperview() }
        backView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        addSubview(containerView)
        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        // frontView UI
        frontView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(30)
            make.centerY.equalToSuperview()
        }
        
        frontView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(24.5)
        }
        
        frontView.addSubview(clockIcon)
        clockIcon.snp.makeConstraints { make in
            make.leading.equalTo(label.snp.leading)
            make.top.equalTo(label.snp.bottom).offset(10.5)
            make.width.height.equalTo(16)
        }
        
        frontView.addSubview(clockLabel)
        clockLabel.snp.makeConstraints { make in
            make.top.equalTo(clockIcon.snp.top).offset(-2.5)
            make.centerY.equalTo(clockIcon.snp.centerY)
            make.leading.equalTo(clockIcon.snp.trailing).offset(4)
        }
        
        frontView.addSubview(button)
        button.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        // backView UI
        backView.addSubview(backIcon)
        backIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(30)
            make.centerY.equalToSuperview()
        }
        
        backView.addSubview(backLabel)
        backLabel.snp.makeConstraints { make in
            make.leading.equalTo(backIcon.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.top.equalTo(backIcon.snp.top).offset(9.5)
            make.centerY.equalTo(backIcon)

        }
    }
    
    private func setupActions() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        containerView.addGestureRecognizer(gesture)
    }
    
    @objc private func onTap() {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        
        isFlipped.toggle()
        
        UIView.transition(with: containerView, duration: 0.3, options: transitionOptions, animations: {
            self.frontView.isHidden = self.isFlipped
            self.backView.isHidden = !self.isFlipped
        })
    }
    
    func updateTitle(title: String, time: String, content: String) {
        label.text = title
        clockLabel.text = time
        backLabel.text = content
    }
}
