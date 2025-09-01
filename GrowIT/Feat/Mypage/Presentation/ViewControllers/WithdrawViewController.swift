//
//  WithdrawViewController.swift
//  GrowIT
//
//  Created by 오현민 on 8/30/25.
//

import UIKit
import Kingfisher

class WithdrawViewController: UIViewController {
    // MARK: - Data
    private var reasons: [WithdrwalReasonsResponseDTO] = []
    private var selectedReasonId: Int?
    
    // MARK: - Properties
    let navigationBarManager = NavigationManager()
    let userService = UserService()
    let withdrawalService = WithdrwalService()
    let authService = AuthService()
    
    // MARK: - View
    private lazy var withdrawView = WithdrawView().then {
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleDropdown))
        $0.dropDownView.addGestureRecognizer(tap)
        $0.cancleButton.addTarget(self, action: #selector(prevVC), for: .touchUpInside)
        $0.withdrawButton.addTarget(self, action: #selector(didTapWithdraw), for: .touchUpInside)
    }
    
    // MARK: - init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(withdrawView)
        withdrawView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        setupNavigationBar()
        setupTableView()
        getWithdrawalReasons()
    }
    
    // MARK: - Network
    // 탈퇴 이유 목록
    private func getWithdrawalReasons() {
        withdrawalService.getWithdrawalReasons(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.reasons = data // 서버 응답 저장
                DispatchQueue.main.async {
                    self.withdrawView.dropdownTableView.reloadData()
                }
            case .failure(let error):
                print("탈퇴이유 불러오기 실패: \(error.localizedDescription)")
            }
        })
    }
    
    // 회원 탈퇴
    private func deleteUser() {
        guard let reasonId = selectedReasonId else { return }
    
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

    // MARK: - SetUI
    private func setupNavigationBar() {
        navigationBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(prevVC),
            tintColor: .black
        )
        
        navigationBarManager.setTitle(
            to: navigationItem,
            title: "내 계정",
            textColor: .black
        )
        
        if let navBar = navigationController?.navigationBar {
            navigationBarManager.addBottomLine(to: navBar)
        }
    }
    
    private func setupTableView() {
        withdrawView.dropdownTableView.delegate = self
        withdrawView.dropdownTableView.dataSource = self
        withdrawView.dropdownTableView.register(WithdrawTableViewCell.self, forCellReuseIdentifier: WithdrawTableViewCell.identifier)
        withdrawView.dropdownTableView.rowHeight = 48
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
    
    // MARK: Event
    @objc
    private func prevVC() {
        if let nav = navigationController {
            if let targetVC = nav.viewControllers.first(where: { $0 is MyAccountViewController }) {
                nav.popToViewController(targetVC, animated: true)
            }
        }
    }
    
    @objc
    private func didTapWithdraw() {
        deleteUser()
    }
    
    @objc
    private func toggleDropdown() {
        let tableView = withdrawView.dropdownTableView
        
        if tableView.isHidden {
            tableView.alpha = 0
            tableView.isHidden = false
            UIView.animate(withDuration: 0.2) {
                tableView.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                tableView.alpha = 0
            }) { _ in
                tableView.isHidden = true
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension WithdrawViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reasons.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WithdrawTableViewCell.identifier,
            for: indexPath
        ) as? WithdrawTableViewCell else { return UITableViewCell() }
        
        cell.configure(mainText: reasons[indexPath.row].reason)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = reasons[indexPath.row]
        
        withdrawView.dropDownLabel.text = selected.reason
        withdrawView.dropDownLabel.textColor = .gray900
        
        selectedReasonId = selected.id // id 저장
        
        tableView.isHidden = true
        withdrawView.buttonStackView.isHidden = false
    }
}
