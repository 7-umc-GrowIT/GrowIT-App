//
//  MyAccountViewController.swift
//  GrowIT
//
//  Created by 오현민 on 7/12/25.
//

import UIKit

class MyAccountViewController: UIViewController {
    // MARK: Properties
    let navigationBarManager = NavigationManager()
    let userService = UserService()
    
    //MARK: - Data
    private var tableviewData: [[(main: String, sub: String)]] = [
        // 섹션 1 : 회원정보 변경
        [("닉네임", "샤샤"), ("비밀번호 변경", "변경하기")],
        // 섹션 2 : 이용약관
        [("개인정보 수집•이용 동의", ""),("서비스 이용약관", "")]
    ]
    
    // MARK: - Views
    private lazy var myAccountView = MyAccountView().then {
        $0.logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        $0.withdrawButton.addTarget(self, action: #selector(didTapWithdraw), for: .touchUpInside)
    }
    
    //MARK: - init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        callGetMypage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(myAccountView)
        myAccountView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        setupNavigationBar()
        setupTableView()
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(navigateToWithdraw),
            name: NSNotification.Name("NavigateToWithdraw"),
            object: nil
        )
        
    }
    
    // MARK: - NetWork
    func callGetMypage() {
        userService.getMypage(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                print(data.name)
                self.tableviewData[0][0].1 = data.name
                DispatchQueue.main.async {
                    self.myAccountView.myAccounttableView.reloadRows(
                        at: [IndexPath(row: 0, section: 0)],
                        with: .automatic
                    )
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    //MARK: - Functional
    //MARK: Event
    @objc
    func didTapChangeNickname() {
        let editNameVC = EditNameModalViewController()
        editNameVC.modalPresentationStyle = .pageSheet
        
        // 닉네임 변경 시 테이블 즉시 반영
        editNameVC.onNicknameChanged = { [weak self] newName in
            guard let self = self else { return }
            self.tableviewData[0][0].1 = newName
            self.myAccountView.myAccounttableView.reloadRows(
                at: [IndexPath(row: 0, section: 0)],
                with: .automatic
            )
        }
        
        presentSheet(editNameVC, heightRatio: 0.32)
    }
    
    @objc
    func didTapLogout() {
        let logoutVC = LogoutModalViewController()
        logoutVC.modalPresentationStyle = .pageSheet
        presentSheet(logoutVC, heightRatio: 0.27)
    }
    
    @objc private func navigateToWithdraw() {
        // 탈퇴 시 닉네임 넘겨주기
        let nickname = tableviewData[0][0].1
        
        let nextVC = WithdrawViewController(nickname: nickname)
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc
    func didTapWithdraw() {
        // Notification 이용 방식
        let withDrawModalVC = WithdrawModalViewController()
        withDrawModalVC.modalPresentationStyle = .pageSheet
        
        presentSheet(withDrawModalVC, heightRatio: 0.34)
    }
    
    @objc
    func didTapTermsOfService(_ type: String) {
        let nextVC = TermsOfServiceViewController(navigationBarTitle: type)
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc
    func changePwdBtnTap() {
        let changePwdVC = ChangePasswordViewController(isMypage: true)
        changePwdVC.shouldShowExitModal = false
        navigationController?.pushViewController(changePwdVC, animated: true)
    }
    
    //MARK: - Setup UI
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
        myAccountView.myAccounttableView.delegate = self
        myAccountView.myAccounttableView.dataSource = self
        myAccountView.myAccounttableView.register(MypageTableViewCell.self, forCellReuseIdentifier: MypageTableViewCell.identifier)
        myAccountView.myAccounttableView.rowHeight = 66
    }
    
    @objc
    private func prevVC() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension MyAccountViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableviewData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableviewData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //테스트
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MypageTableViewCell.identifier, for: indexPath) as? MypageTableViewCell else {
            return UITableViewCell()
        }
        
        let (mainText, subText) = tableviewData[indexPath.section][indexPath.row]
        cell.configure(mainText: mainText, subText: subText)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            didTapChangeNickname()
        case (0, 1):
            let provider = UserDefaults.standard.string(forKey: "loginMethod")
            if provider == "LOCAL" {
                changePwdBtnTap()
            } else {
               
                let modalVC = CannotChangePasswordViewController()
                modalVC.modalPresentationStyle = .pageSheet
                presentSheet(modalVC, heightRatio: 0.36)
            }
        case (1, 0):
            didTapTermsOfService("개인정보 수집•이용 동의")
        case (1, 1):
            didTapTermsOfService("서비스 이용약관")
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "회원정보 변경"
        case 1: return "이용약관"
        default: return nil
        }
    }
}
