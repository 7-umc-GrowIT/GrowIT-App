//
//  LogoutModalViewController.swift
//  GrowIT
//
//  Created by 오현민 on 7/15/25.
//

import UIKit

class LogoutModalViewController: UIViewController {
    //MARK: -Views
    private lazy var logoutModalView = TwoButtonModalView(
        title: "로그아웃 할까요?",
        desc: "다음 로그인을 할 때 이메일로 로그인해 주세요",
        mainBtn: "로그아웃하기",
        subBtn: "취소").then {
            $0.mainButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
            $0.subButton.addTarget(self, action: #selector(didTapCancleButton), for: .touchUpInside)
        }

    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = logoutModalView
    }
    
    //MARK: - Functional
    //MARK: Event
    @objc private func didTapLogout(){
        TokenManager.shared.clearTokens()
        let nextVC = LoginViewController()
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = nextVC
            window.makeKeyAndVisible()
            
            // 뷰 컨트롤러 전환 시 애니메이션을 제공합니다.
            UIView.transition(with: window, duration: 0.1, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    @objc
    private func didTapCancleButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
