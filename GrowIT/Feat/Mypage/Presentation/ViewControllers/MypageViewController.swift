//
//  MypageViewController.swift
//  GrowIT
//
//  Created by 오현민 on 6/9/25.
//

import UIKit

class MypageViewController: UIViewController {
    // MARK: - Properties
    let userService = UserService()
    var categoryToEquippedId: [String: Int] = [:]
    let navigationBarManager = NavigationManager()

    //MARK: - Data
    private let tableviewData: [[(main: String, sub: String)]] = [
        // 섹션 1 : 구독 내역
        [("멤버십 구독 내역", ""), ("크레딧 결제 내역", "")],
        // 섹션 2 : 문의 및 알림
        [("푸시 알림 활성화/비활성화", ""),("고객센터", ""),("데이터 초기화", "")]
    ]
    
    // MARK: - View
    private lazy var mypageView = MypageView().then {
        $0.editProfileButton.addTarget(self, action: #selector(goToEditProfile), for: .touchUpInside)
    }
    
    //MARK: - init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        callGetMypage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mypageView)
        mypageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        setupNavigationBar()
        setupTableView()
        loadGroImage()
        setNotification()
        
        // 개발 중: 프로필 영역만 노출
        mypageView.hideForDevelopment()
    }
    
    // MARK: - NetWork
    func callGetMypage() {
        userService.getMypage(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                mypageView.nicknameLabel.text = data.name
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        })
    }
   
    //MARK: - Functional
    //MARK: Event
    @objc
    private func prevVC() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func goToEditProfile() {
        let myAccountVC = MyAccountViewController()
        navigationController?.pushViewController(myAccountVC, animated: true)
    }
    
    @objc
    func didTapResetData() {
        let resetDataVC = ResetDataModalViewController()
        resetDataVC.modalPresentationStyle = .pageSheet
        if let sheet = resetDataVC.sheetPresentationController {
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
        present(resetDataVC, animated: true, completion: nil)
    }
    
    //MARK: Notification
    private func setNotification() {
        let Notification = NotificationCenter.default
        
        Notification.addObserver(self, selector: #selector(didCompleteChangeNickname), name: .purchaseCompleted, object: nil)
    }
    
    @objc
    func didCompleteChangeNickname() {
        ToastSecond.show(image: UIImage(named: "toast_Icon") ?? UIImage(), message: "닉네임을 변경했어요", font: .heading3SemiBold(), in: self.view)
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
            title: "마이페이지",
            textColor: .black
        )
        
        if let navBar = navigationController?.navigationBar {
            navigationBarManager.addBottomLine(to: navBar)
        }
    }
    
    private func setupTableView() {
        mypageView.myPagetableView.delegate = self
        mypageView.myPagetableView.dataSource = self
        mypageView.myPagetableView.register(MypageTableViewCell.self, forCellReuseIdentifier: MypageTableViewCell.identifier)
        mypageView.myPagetableView.rowHeight = 66
    }
    
    private func loadGroImage() {
        GroImageCacheManager.shared.fetchGroImage { [weak self] data in
            guard let self = self, let data = data else { return }
            self.setupProfileGroImage(with: data)
        }
    }
    
    private func setupProfileGroImage(with data: GroGetResponseDTO) {
        mypageView.groFaceImageView.kf.setImage(with: URL(string: data.gro.groImageUrl), options: [.transition(.fade(0.3)), .cacheOriginalImage])
        
        let categoryImageViews: [String: UIImageView] = [
            "BACKGROUND": mypageView.backgroundImageView,
            "OBJECT": mypageView.groObjectImageView,
            "PLANT": mypageView.groFlowerPotImageView,
            "HEAD_ACCESSORY": mypageView.groAccImageView
        ]
        
        categoryToEquippedId = data.equippedItems.reduce(into: [String: Int]()) { dict, item in
            dict[item.category] = item.id
        }
        
        for item in data.equippedItems {
            if let imageView = categoryImageViews[item.category] {
                imageView.kf.setImage(with: URL(string: item.itemImageUrl), options: [.transition(.fade(0.3)), .cacheOriginalImage])
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension MypageViewController: UITableViewDataSource, UITableViewDelegate {
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
        print("섹션 \(indexPath.section), 행 \(indexPath.row)")
        // 나중에 섹션,행 별로 이벤트 설정
        if indexPath.section == 1, indexPath.row == 2 {
            didTapResetData()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "구독 내역"
        case 1: return "문의 및 알림"
        default: return nil
        }
    }
} 
