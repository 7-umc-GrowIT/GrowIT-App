//
//  TermsDetailViewController.swift
//  GrowIT
//
//  Created by 강희정 on 2/18/25.
//

import UIKit

class TermsDetailViewController: UIViewController, UITextViewDelegate {
    
    // MARK: Properties
    let navigationBarManager = NavigationManager()
    let termsDetailView = TermsDetailView()
    var termsContent: String?
    var termId: Int?
    
    // 동의 완료 후 콜백
    var onAgreeCompletion: ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        configureContent()
    }
    
    private func setupUI() {
        view.addSubview(termsDetailView)
        termsDetailView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        termsDetailView.contentTextView.delegate = self
        
        self.navigationController?.isNavigationBarHidden = false
        
        navigationBarManager.setTitle(
            to: self.navigationItem,
            title: "개인정보 수집이용",
            textColor: .gray900,
            font: .heading1Bold()
        )
        
        navigationBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(prevVC)
        )
    }
    
    private func setupActions() {
        termsDetailView.agreeButton.addTarget(self, action: #selector(agreeButtonTapped), for: .touchUpInside)
    }
    
    private func configureContent() {
        termsDetailView.configure(content: termsContent ?? "약관 내용이 없습니다.")
    }
    
    // 스크롤 끝까지 하면 동의 버튼 활성화
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.height
        
        if offsetY + scrollViewHeight >= contentHeight - 10 {
            termsDetailView.agreeButton.isEnabled = true
            termsDetailView.agreeButton.backgroundColor = .gray900
            termsDetailView.agreeButton.setTitleColor(.white, for: .normal)
        }
    }
    
    @objc private func agreeButtonTapped() {
        guard let termId = termId else { return }
        onAgreeCompletion?(termId)
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - func
    @objc private func prevVC() {
        navigationController?.popViewController(animated: true)
    }

}
