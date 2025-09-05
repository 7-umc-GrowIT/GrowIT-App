//
//  SceneDelegate.swift
//  GrowIT
//
//  Created by 허준호 on 1/7/25.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKCommon

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        window?.makeKeyAndVisible()
        
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        var mainVC: UIViewController
        
        if !hasLaunchedBefore {
            mainVC = OnboardingViewController()
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        } else {
            if let _ = TokenManager.shared.getAccessToken() {
                mainVC = CustomTabBarController(initialIndex: 1)
            } else {
                mainVC = LoginViewController()
            }
        }
        
        let navigationController = UINavigationController(rootViewController: mainVC)
        
        // 부드럽게 전환
        UIView.transition(with: self.window!,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.window?.rootViewController = navigationController
        })
    }

    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // 카카오 로그인 등 URL 스킴 처리
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {
        // 개발용: 필요하다면 주석 해제
        // TokenManager.shared.clearTokens()
    }
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
