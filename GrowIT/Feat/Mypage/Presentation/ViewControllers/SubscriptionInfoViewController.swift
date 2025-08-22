//
//  SubcriptionInfoViewController.swift
//  GrowIT
//
//  Created by 오현민 on 7/30/25.
//

import UIKit

class SubscriptionInfoViewController: UIViewController {
    //MARK: - Data
    private let tableviewData: [(main: String, sub: String)] = [("결제 내역", ""), ("결제 수단", "")]
    
    // MARK: Properties
    let navigationBarManager = NavigationManager()
    private lazy var subInfoView = SubscriptionInfoView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //MARK: - init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(subInfoView)
        subInfoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        setupNavigationBar()
        setupTableView()
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
        subInfoView.subscriptionInfoTableView.delegate = self
        subInfoView.subscriptionInfoTableView.dataSource = self
        subInfoView.subscriptionInfoTableView.register(MypageTableViewCell.self, forCellReuseIdentifier: MypageTableViewCell.identifier)
        subInfoView.subscriptionInfoTableView.rowHeight = 66
    }

    //MARK: - Functional
    //MARK: Event
    @objc
    private func prevVC() {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension SubscriptionInfoViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableviewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //테스트
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MypageTableViewCell.identifier, for: indexPath) as? MypageTableViewCell else {
            return UITableViewCell()
        }
        
        let (mainText, subText) = tableviewData[indexPath.row]
        cell.configure(mainText: mainText, subText: subText)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("섹션 \(indexPath.section), 행 \(indexPath.row)")
        // 나중에 섹션,행 별로 이벤트 설정
            }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "구독 관리"
        default: return nil
        }
    }
}
