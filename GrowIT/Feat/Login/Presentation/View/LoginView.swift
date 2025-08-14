//
//  LoginView.swift
//  GrowIT
//
//  Created by 강희정 on 1/12/25.
//

import UIKit
import Then
import SnapKit

class LoginView: UIView {

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
    
    // 타이틀 라벨
    private lazy var titleLabel = UILabel().then {
            $0.font = .subHeading2()
            $0.textColor = .grayColor800
            $0.textAlignment = .center
            $0.text = "AI와 대화하며 성장하다"
            $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // 로고 이미지
    private lazy var logoImageView = UIImageView().then {
        $0.image = UIImage(named: "loginTitle")
        $0.contentMode = .scaleAspectFill
    }
    
    // 카카오 로그인 버튼
    public lazy var kakaoLoginButton = UIButton().then {
        // 배경색 및 스타일 설정
        $0.backgroundColor = UIColor.kakao
        $0.layer.cornerRadius = 30
        $0.layer.borderColor = UIColor(named: "kakaoBorder")?.cgColor ?? UIColor.gray.cgColor
        $0.layer.borderWidth = 1
        $0.layer.masksToBounds = true
        
        // 아이콘 추가
        let icon = UIImageView()
        icon.image = UIImage(named: "kakao")
        $0.addSubview(icon)
        icon.snp.makeConstraints {
            $0.leading.equalTo(24)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(24)
            $0.width.equalTo(24)
        }
        
        // 타이틀 설정
            let titleAttribute = NSAttributedString(
                string: "카카오로 시작하기",
                attributes: [
                    .font: UIFont.heading3SemiBold(),
                    .foregroundColor: UIColor.grayColor900 ?? .black
                ]
            )
            $0.setAttributedTitle(titleAttribute, for: .normal)
    }
    
    // 애플 로그인 버튼
    private lazy var appleLoginButton = UIButton().then {
        // 배경색 및 스타일 설정
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 30
        $0.layer.masksToBounds = true
        
        // 아이콘 추가
        let icon = UIImageView()
        icon.image = UIImage(named: "apple")
        $0.addSubview(icon)
        icon.snp.makeConstraints {
            $0.leading.equalTo(24)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(24)
            $0.width.equalTo(21)
        }
        
        // 타이틀 설정
            let titleAttribute = NSAttributedString(
                string: "Apple로 시작하기",
                attributes: [
                    .font: UIFont.heading3SemiBold(),
                    .foregroundColor: UIColor.white
                ]
            )
            $0.setAttributedTitle(titleAttribute, for: .normal)
    }
    
    // 이메일 로그인 버튼
    public lazy var emailLoginButton = UIButton().then {
        // 배경 및 스타일 설정
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 30
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray300.cgColor
        $0.layer.masksToBounds = true
        
        // 아이콘 추가
        let icon = UIImageView()
        icon.image = UIImage(named: "email")
        $0.addSubview(icon)
        icon.snp.makeConstraints {
            $0.leading.equalTo(24)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(28)
            $0.width.equalTo(28)
        }
        
        // 타이틀 설정
            let titleAttribute = NSAttributedString(
                string: "이메일로 시작하기",
                attributes: [
                    .font: UIFont.heading3SemiBold(),
                    .foregroundColor: UIColor.grayColor900 ?? .black
                ]
            )
            $0.setAttributedTitle(titleAttribute, for: .normal)
    }
    
    // 계정 찾기 버튼
    private lazy var findAccountButton = UIButton().then {
        
        // 타이틀 속성
        let titleAttribute = NSAttributedString(
            string: "계정 찾기",
            attributes: [
                .font: UIFont.body2Medium(),
                .foregroundColor: UIColor.grayColor400 ?? .gray
            ]
        )
        $0.setAttributedTitle(titleAttribute, for: .normal)

        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - add Function & Constraints
    
    private func addComponents() {
        [titleLabel, logoImageView, kakaoLoginButton,
         appleLoginButton, emailLoginButton, findAccountButton]
            .forEach(self.addSubview)
    }
    
    private func constraints() {
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(200)
            $0.centerX.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(54)
        }
        
        kakaoLoginButton.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(200)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }
        
        appleLoginButton.snp.makeConstraints {
            $0.top.equalTo(kakaoLoginButton.snp.bottom).offset(9)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }
        
        emailLoginButton.snp.makeConstraints {
            $0.top.equalTo(appleLoginButton.snp.bottom).offset(39)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }
        
        findAccountButton.snp.makeConstraints {
            $0.top.equalTo(emailLoginButton.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }
    
}
