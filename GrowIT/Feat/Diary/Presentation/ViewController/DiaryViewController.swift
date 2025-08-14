////
////  DiaryViewController.swift
////  GrowIT
////
////  Created by 이수현 on 1/11/25.
////
//
//import Foundation
//import SnapKit
//import SwiftyToaster
//
//class DiaryViewController: UIViewController {
//    
//    let navigationBarManager = NavigationManager()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.navigationController?.isNavigationBarHidden = false
//        view.backgroundColor = .white
//        view.addSubview(button)
//        button.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(24)
//            make.centerY.equalToSuperview()
//        }
//        setupNavigationBar()
//        button.addTarget(self, action: #selector(nextVC), for: .touchUpInside)
//        
//        Toast.show(image: UIImage(named: "bath") ?? UIImage(), message: "asdfasdfa", font: .heading3SemiBold())
//    }
//    
//    private func setupNavigationBar() {
//        navigationBarManager.addBackButton(
//            to: navigationItem,
//            target: self,
//            action: #selector(prevVC),
//            tintColor: .black
//        )
//        
//        navigationBarManager.setTitle(
//            to: navigationItem,
//            title: "직접 일기 작성하기",
//            textColor: .black
//        )
//    }
//    
//    let button = AppButton(title: "확인했어요", titleColor: .black, isEnabled: true)
//    
//    @objc func nextVC() {
//        let nextVC = TextDiaryRecommendChallengeViewController()
//        navigationController?.pushViewController(nextVC, animated: true)
//    }
//    
//    @objc func prevVC() {
//        navigationController?.popViewController(animated: true)
//    }
//}
