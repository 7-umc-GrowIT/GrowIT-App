//
//  SignUpCompleteView.swift
//  GrowIT
//
//  Created by 강희정 on 1/26/25.
//

import UIKit
import Then
import SnapKit

class SignUpCompleteView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        addComponents()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    
    public lazy var mainLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .left
        $0.font = UIFont.subTitle1()
        $0.textColor = .gray900
        $0.text = "회원가입 완료!\n그로우잇에 온 걸 환영해요!"
    }
    
    public lazy var mainImage = UIImageView().then {
        $0.image = UIImage(named: "grow")
        $0.contentMode = .scaleAspectFill
    }
    
    public lazy var loginButton = AppButton(
        title: "그로 만들러 가기",
        titleColor: .white,
        isEnabled: true
    ).then {
        $0.setButtonState(
            isEnabled: true, enabledColor: .black, disabledColor: .gray100, enabledTitleColor: .white, disabledTitleColor: .gray400)
    }
    
    // MARK: - Constraints
    private func addComponents() {
        [mainLabel, mainImage, loginButton]
            .forEach(self.addSubview)
    }
    
    private func constraints() {
        mainLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(148)
            $0.leading.equalToSuperview().offset(24)
        }
        
        mainImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        loginButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-40)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }
    }
}
