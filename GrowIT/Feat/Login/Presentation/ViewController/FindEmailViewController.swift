//
//  FindEmailViewController.swift
//  GrowIT
//
//  Created by 강희정 on 1/26/25.
//

import UIKit

class FindEmailViewController: UIViewController {
    
    // MARK: - Properties
    private let findEmailView = FindEmailView()
    private let navigationBarManager = NavigationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - setupView
    private func setupView() {
        self.view = findEmailView
        self.navigationController?.isNavigationBarHidden = false
        
        navigationBarManager.setTitle(
            to: self.navigationItem,
            title: "이메일 찾기",
            textColor: .gray900,
            font: .heading1Bold()
        )
        
        navigationBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(prevVC)
        )
    }
    
    // MARK: - Actions
    @objc private func prevVC() {
        navigationController?.popViewController(animated: true)
    }


}
