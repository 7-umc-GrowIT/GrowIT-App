//
//  HomeViewController.swift
//  GrowIT
//
//  Created by 허준호 on 1/7/25.
//

import UIKit

class HomeViewController: UIViewController {
    let groService = GroService()
    let userService = UserService()
    private var isFirstAppear: Bool = true // 화면 최초 등장 여부를 확인하는 변수 추가
    
    private lazy var gradientView = UIView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = homeview
        loadGroImage()
        setNotification()
        callGetCredit()
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //setupGradientView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCharacterView()
        DispatchQueue.main.async {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }


    func callGetCredit() {
        userService.getUserCredits(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                homeview.characterArea.creditNum.text = "\(data.currentCredit)개"
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    // MARK: - Set Character
    private func loadGroImage() {
        GroImageCacheManager.shared.fetchGroImage { [weak self] data in
            guard let self = self, let data = data else { return }
            self.updateCharacterViewImage(with: data)
        }
    }
    
    @objc
    private func updateCharacterView() {
        GroImageCacheManager.shared.fetchGroImage { [weak self] data in
            guard let self = self, let data = data else { return }
            DispatchQueue.main.async {
                self.updateCharacterViewImage(with: data)
            }
        }
    }

    
    private func updateCharacterViewImage(with data: GroGetResponseDTO) {
        // 얼굴 이미지 업데이트
        if let groImageUrl = URL(string: data.gro.groImageUrl) {
            homeview.characterArea.groFaceImageView.kf.setImage(with: groImageUrl, options: [.transition(.fade(0.3)), .cacheOriginalImage])
        } else {
            print("얼굴 이미지 URL이 유효하지 않음")
        }

        // 카테고리별 이미지 뷰 매핑
        let categoryImageViews: [String: UIImageView] = [
            "BACKGROUND": homeview.characterArea.backgroundImageView,
            "OBJECT": homeview.characterArea.groObjectImageView,
            "PLANT": homeview.characterArea.groFlowerPotImageView,
            "HEAD_ACCESSORY": homeview.characterArea.groAccImageView
        ]
        
        // 기존 이미지 초기화 (이미 착용한 아이템 제거)
        for (_, imageView) in categoryImageViews {
            imageView.image = nil
        }

        for item in data.equippedItems {
            if let imageView = categoryImageViews[item.category], let imageUrl = URL(string: item.itemImageUrl) {
                imageView.kf.setImage(with: imageUrl, options: [.transition(.fade(0.3)), .cacheOriginalImage])
            } else {
                print("잘못된 카테고리: \(item.category) 또는 유효하지 않은 URL")
            }
        }
    }
    
    //MARK: -
    private func setupGradientView() {
        // 그라디언트 뷰의 프레임 설정
        gradientView.frame = CGRect(x: 0, y: view.bounds.height / 2, width: view.bounds.width, height: view.bounds.height / 2 - 20)
        view.addSubview(gradientView)
        
        // 그라디언트 레이어 생성 및 설정
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [
            UIColor.gray.withAlphaComponent(0).cgColor,
            UIColor.gray.withAlphaComponent(0.2).cgColor,
            UIColor.gray.withAlphaComponent(0.6).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        // 그라디언트 레이어를 뷰에 추가
        gradientView.layer.addSublayer(gradientLayer)
    }
    
    private lazy var homeview = HomeView().then {
        $0.topNavBar.itemShopBtn.addTarget(self, action: #selector(goToItemShop), for: .touchUpInside)
        $0.topNavBar.settingBtn.addTarget(self, action: #selector(logout), for: .touchUpInside)
    }
    
    @objc private func goToItemShop() {
        let itemShopVC = GroViewController()
        navigationController?.pushViewController(itemShopVC, animated: false)
    }
    
    @objc private func logout(){
        TokenManager.shared.clearTokens()
        let nextVC = LoginViewController()
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = nextVC
            window.makeKeyAndVisible()
            
            // 뷰 컨트롤러 전환 시 애니메이션을 제공합니다.
            UIView.transition(with: window, duration: 0.1, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
        
    //MARK: Notification
    private func setNotification() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(updateCharacterView), name: .groImageUpdated, object: nil)
    }
}
