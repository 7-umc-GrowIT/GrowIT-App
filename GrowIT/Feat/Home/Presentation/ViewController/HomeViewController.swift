//
//  HomeViewController.swift
//  GrowIT
//
//  Created by 허준호 on 1/7/25.
//

import UIKit
import Kingfisher

class HomeViewController: UIViewController {
    let groService = GroService()
    let userService = UserService()
    private var isFirstAppear: Bool = true // 화면 최초 등장 여부를 확인하는 변수 추가
    
    private lazy var gradientView = UIView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = homeview
        loadGroImage()
        setNotification()
        callGetCredit()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        let categoryImageViews: [String: UIImageView] = [
            "BACKGROUND": homeview.characterArea.backgroundImageView,
            "OBJECT": homeview.characterArea.groObjectImageView,
            "PLANT": homeview.characterArea.groFlowerPotImageView,
            "HEAD_ACCESSORY": homeview.characterArea.groAccImageView
        ]
        
        let shouldAnimate = isFirstAppear   // 처음 진입일 때만 true

        let group = DispatchGroup()
        var loadedImages: [String: (UIImageView, UIImage)] = [:]

        // 얼굴
        if let faceUrl = URL(string: data.gro.groImageUrl) {
            group.enter()
            KingfisherManager.shared.retrieveImage(with: faceUrl) { result in
                if case .success(let value) = result {
                    loadedImages["FACE"] = (self.homeview.characterArea.groFaceImageView, value.image)
                }
                group.leave()
            }
        }

        // 아이템들
        for item in data.equippedItems {
            if let imageView = categoryImageViews[item.category],
               let url = URL(string: item.itemImageUrl) {
                group.enter()
                KingfisherManager.shared.retrieveImage(with: url) { result in
                    if case .success(let value) = result {
                        loadedImages[item.category] = (imageView, value.image)
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            if shouldAnimate {
                // 최초 로딩일 때만 페이드인
                for (_, pair) in loadedImages {
                    let (imageView, image) = pair
                    imageView.alpha = 0.0
                    imageView.image = image
                }
                UIView.animate(withDuration: 0.8) {
                    for (_, pair) in loadedImages {
                        pair.0.alpha = 1.0
                    }
                }
                self.isFirstAppear = false   // 이후부턴 애니메이션 X
            } else {
                // 그냥 즉시 반영
                for (_, pair) in loadedImages {
                    pair.0.image = pair.1
                }
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
        $0.topNavBar.settingBtn.addTarget(self, action: #selector(goToMypage), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(friendBtnTapped))
        $0.characterArea.friendContainer.addGestureRecognizer(tapGesture)
        $0.characterArea.friendContainer.isUserInteractionEnabled = true
    }
    
    @objc private func goToItemShop() {
        let itemShopVC = GroViewController()
        navigationController?.pushViewController(itemShopVC, animated: false)
    }
    
    @objc private func goToMypage() {
        let nextVC = MypageViewController()
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc private func friendBtnTapped() {
        let modalVC = FriendReadyModalViewController()
        
        // 바텀 시트 설정
        modalVC.modalPresentationStyle = .pageSheet
        
        if let sheet = modalVC.sheetPresentationController {
            // iOS 16 이상
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in return 300 }] // 원하는 높이
            } else {
                // iOS 15
                sheet.detents = [.medium()]
            }
            
            sheet.preferredCornerRadius = 20
            sheet.prefersGrabberVisible = false
        }
        
        present(modalVC, animated: true)
    }
        
    //MARK: Notification
    private func setNotification() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(updateCharacterView), name: .groImageUpdated, object: nil)
    }
}
