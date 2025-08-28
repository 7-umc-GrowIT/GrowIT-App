//
//  TermsOfServiceViewController.swift
//  GrowIT
//
//  Created by 오현민 on 8/29/25.
//

import UIKit

class TermsOfServiceViewController: UIViewController {
    let navigationBarManager = NavigationManager()

    // MARK: - View
    private lazy var tosView = TermsOfServiceView()
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tosView)
        tosView .snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
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
            title: "서비스 이용약관",
            textColor: .black
        )
        
        if let navBar = navigationController?.navigationBar {
            navigationBarManager.addBottomLine(to: navBar)
        }
    }

    //MARK: - Functional
    //MARK: Event
    @objc
    private func prevVC() {
        navigationController?.popViewController(animated: true)
    }
    
}
