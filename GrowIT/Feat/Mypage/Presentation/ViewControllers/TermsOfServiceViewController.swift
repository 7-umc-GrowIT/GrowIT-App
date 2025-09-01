//
//  TermsOfServiceViewController.swift
//  GrowIT
//
//  Created by 오현민 on 8/29/25.
//

import UIKit

class TermsOfServiceViewController: UIViewController {
    let navigationBarManager = NavigationManager()
    let termsService = TermsService()
    let navigationBarTitle: String
    // MARK: - View
    private lazy var tosView = TermsOfServiceView()
    
    //MARK: - init
    init(navigationBarTitle: String) {
        self.navigationBarTitle = navigationBarTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tosView)
        tosView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setupNavigationBar()
        callGetTerms()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Network
    private func callGetTerms() {
        termsService.getTerms { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let terms):
                    var matchedTerm: TermsData?

                    if self.navigationBarTitle == "서비스 이용약관" {
                        matchedTerm = terms.first { $0.title == "그로우잇 이용약관" }
                    } else if self.navigationBarTitle == "개인정보 처리방침" {
                        matchedTerm = terms.first { $0.title == "개인정보 처리방침" }
                    }

                    if let term = matchedTerm {
                        self.tosView.contents = term.content
                        self.tosView.contentLabel.text = term.content
                    }

                case .failure(let error):
                    print("약관 불러오기 실패: \(error.localizedDescription)")
                }
            }
        }
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
            title: navigationBarTitle,
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
