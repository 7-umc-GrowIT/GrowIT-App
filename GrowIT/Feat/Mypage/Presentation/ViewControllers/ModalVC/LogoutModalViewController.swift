//
//  LogoutModalViewController.swift
//  GrowIT
//
//  Created by 오현민 on 7/15/25.
//

import UIKit
import Kingfisher

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
        TokenManager.shared.clearTokens()  // 토큰 삭제
        GroImageCacheManager.shared.clearAll() //  DTO 캐시 삭제
        // 🧹 이미지 캐시 삭제
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache {
            print("🗑️ Kingfisher 디스크 캐시 초기화 완료")
        }
        
        // 로그인 화면으로 전환
        let loginVC = LoginViewController()
        let nav = UINavigationController(rootViewController: loginVC)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
            UIView.transition(with: window,
                              duration: 0.1,
                              options: .transitionCrossDissolve,
                              animations: nil,
                              completion: nil)
        }
    }
    
    @objc
    private func didTapCancleButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
