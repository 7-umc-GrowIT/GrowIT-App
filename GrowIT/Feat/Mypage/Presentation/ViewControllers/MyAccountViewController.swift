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
    let groName: String = ""
    
    //MARK: - Data
    private var tableviewData: [[(main: String, sub: String)]] = [
        // 섹션 1 : 회원정보 변경
        [("닉네임", "샤샤"), ("비밀번호 변경", "변경하기")],
        // 섹션 2 : 이용약관
        [("개인정보 처리방침", ""),("서비스 이용약관", "")]
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
        
        if let sheet = editNameVC.sheetPresentationController {
            //지원할 크기 지정
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .custom{ context in
                        0.33 * context.maximumDetentValue
                    }
                ]
            } else { sheet.detents = [.medium()] }
            sheet.prefersGrabberVisible = true
        }
        present(editNameVC, animated: true, completion: nil)
    }
    
    @objc
    func didTapLogout() {
        let logoutVC = LogoutModalViewController()
        logoutVC.modalPresentationStyle = .pageSheet
        if let sheet = logoutVC.sheetPresentationController {
            //지원할 크기 지정
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .custom{ context in
                        0.28 * context.maximumDetentValue
                    }
                ]
            } else { sheet.detents = [.medium()] }
            sheet.prefersGrabberVisible = true
        }
        present(logoutVC, animated: true, completion: nil)
    }
    
    // 회원탈퇴 모달 -> 뷰로 구현
    private weak var dimmedView: UIView?
    private weak var sheetView: UIView?
    
    @objc
    func didTapWithdraw() {
        // 불투명 검은 뷰
        let dimmedView = UIView(frame: view.bounds)
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        dimmedView.alpha = 0
        view.addSubview(dimmedView)
        self.dimmedView = dimmedView
        
        // 모달 대체 뷰
        let sheetView = UIView()
        sheetView.backgroundColor = .white
        sheetView.layer.cornerRadius = 40
        sheetView.clipsToBounds = true
        dimmedView.addSubview(sheetView)
        self.sheetView = sheetView
        
        sheetView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(322)
        }
        
        let contentView = WithdrawModalView()
        sheetView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        sheetView.transform = CGAffineTransform(translationX: 0, y: 300)
        UIView.animate(withDuration: 0.25) {
            dimmedView.alpha = 1
            sheetView.transform = .identity
        }
        
        contentView.cancleButton.addTarget(self, action: #selector(dismissWithdrawModal), for: .touchUpInside)
        contentView.withDrawButton.addTarget(self, action: #selector(goWithdrawPage), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissWithdrawModal))
        tap.delegate = self
        dimmedView.addGestureRecognizer(tap)
    }
    
    @objc
    private func dismissWithdrawModal() {
        guard let dimmedView = dimmedView else { return }
        UIView.animate(withDuration: 0.25, animations: {
            dimmedView.alpha = 0
        }) { _ in
            dimmedView.removeFromSuperview()
        }
    }
    
    @objc
    private func goWithdrawPage() {
        dismissWithdrawModal()
        let nextVC = WithdrawViewController()
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc
    func didTapTermsOfService(_ type: String) {
        let nextVC = TermsOfServiceViewController(navigationBarTitle: type)
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc
    func changePwdBtnTap() {
        let changePwdVC = ChangePasswordViewController()
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
    
    @objc private func prevVC() {
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
                print("안돼돌아가")
            }
        case (1, 0):
            didTapTermsOfService("개인정보 처리방침")
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

// MARK: - UIGestureRecognizerDelegate
extension MyAccountViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // sheetView 안쪽 터치면 무시, 배경만 인식
        if let sheetView = sheetView, let tappedView = touch.view {
            if tappedView.isDescendant(of: sheetView) {
                return false
            }
        }
        return true
    }
}
