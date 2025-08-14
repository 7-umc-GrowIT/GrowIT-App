//
//  LaunchScreenViewController.swift
//  GrowIT
//
//  Created by 오현민 on 2/16/25.
//

import UIKit

final class LaunchScreenViewController: UIViewController {
    var isFirstLaunch: Bool = true

    private lazy var titleLabel = UILabel().then {
        $0.text = "AI와 대화하며 성장하다"
        $0.font = UIFont.subHeading2()
        $0.textColor = .grayColor800
        $0.textAlignment = .center
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var logoImageView = UIImageView().then {
        $0.image = UIImage(named: "GROWIT")
        $0.contentMode = .scaleAspectFill
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var groImageView = UIImageView().then {
        $0.image = UIImage(named: "GrowIT_Gro")
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setView()
    }
    
    private func setView() {
        view.addSubviews([titleLabel, logoImageView, groImageView])
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(144)
        }
        
        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(28)
            $0.width.equalTo(286)
            $0.height.equalTo(54)
        }
        
        groImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.height.equalToSuperview().multipliedBy(1.5)
        }
    }
    
    // MARK: - Navigation
        public func navigateToMain() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // 최초 실행 여부 확인
                let isFirstLaunch = UserDefaults.standard.bool(forKey: "HasLaunchedOnce")
                print("isFirst값은 \(isFirstLaunch)")
                var mainVC = UIViewController() // 👉 여기에 진입할 메인 뷰컨트롤러
                
                if !isFirstLaunch {  // isFirstLaunch가 false이면, 최초 실행입니다.
                    // 최초 실행이면 온보딩 화면으로 이동
                    mainVC = OnboardingViewController()
                    UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
                    UserDefaults.standard.synchronize()
                } else {
                    // 최초 실행이 아니면 토큰 확인 후 화면 선택
                    if let _ = TokenManager.shared.getAccessToken() {
                        mainVC =  CustomTabBarController(initialIndex: 1)
                    } else {
                        mainVC = LoginViewController()
                    }
                }
                
                let navigationController = UINavigationController(rootViewController: mainVC)
                UIApplication.shared.windows.first?.rootViewController = navigationController
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        }
}
