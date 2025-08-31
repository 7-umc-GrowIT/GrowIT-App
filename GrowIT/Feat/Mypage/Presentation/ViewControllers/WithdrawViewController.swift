//
//  WithdrawViewController.swift
//  GrowIT
//
//  Created by 오현민 on 8/30/25.
//

import UIKit

class WithdrawViewController: UIViewController {
    // MARK: - Data
    private let tableviewData = [ // 테스트 데이터
        "앱을 잘 사용하지 않게 되었어요",
        "원하는 기능이 부족해요",
        "사용이 복잡하고 불편해요",
        "개인정보 보호가 걱정돼요",
        "기타 사유가 있어요"
    ]
    
    // MARK: - Properties
    let navigationBarManager = NavigationManager()
    
    // MARK: - View
    private lazy var withdrawView = WithdrawView().then {
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleDropdown))
        $0.dropDownView.addGestureRecognizer(tap)
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
        return tableviewData.count // 데이터 개수만큼 row
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WithdrawTableViewCell.identifier,
            for: indexPath
        ) as? WithdrawTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(mainText: tableviewData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedText = tableviewData[indexPath.row]
        withdrawView.dropDownLabel.text = selectedText
        withdrawView.dropDownLabel.textColor = .gray900
        
        tableView.isHidden = true
        withdrawView.buttonStackView.isHidden = false
    }
}
