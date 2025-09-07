//
//  WithdrawFinalViewController.swift
//  GrowIT
//
//  Created by 오현민 on 9/7/25.
// 

import UIKit
import Kingfisher

class WithdrawFinalViewController: UIViewController {
    // MARK: - Properties
    let userService = UserService()
    let authService = AuthService()
    let reasonId: Int?
    
    //MARK: -Views
    private lazy var withdrawFinalModalView = TwoButtonModalView(
        title: "정말로 탈퇴할까요?",
        desc: "탈퇴 시 유의사항을 다시 확인해 주세요\n\n  • 계정 데이터 탈퇴 즉시 삭제",
        mainBtn: "탈퇴하기",
        subBtn: "취소").then {
            $0.mainButton.addTarget(self, action: #selector(didTapWithdraw), for: .touchUpInside)
            $0.subButton.addTarget(self, action: #selector(didTapCancleButton), for: .touchUpInside)
        }
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = withdrawFinalModalView
    }
    
    init(reasonId: Int) {
        self.reasonId = reasonId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Network
    // 회원 탈퇴
    private func deleteUser() {
        guard let reasonId = reasonId else { return }
    
        let requestDTO = UserDeleteRequestDTO(reasonId: reasonId)
        userService.deleteUser(data: requestDTO) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                finishDeleteUser()
                print("탈퇴 성공, 이유번호 : \(reasonId)")
            case .failure(let error):
                print("회원 탈퇴 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Functional
    private func finishDeleteUser() {
        // 토큰 삭제
        TokenManager.shared.clearTokens()
        GroImageCacheManager.shared.clearAll()
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache {
            print("🗑️ Kingfisher 디스크 캐시 초기화 완료")
        }
        
        // 네트워크 요청 취소
        self.authService.provider.session.cancelAllRequests()
        
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
    //MARK: Event
    @objc private func didTapWithdraw(){
        deleteUser()
    }
    
    @objc
    private func didTapCancleButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
