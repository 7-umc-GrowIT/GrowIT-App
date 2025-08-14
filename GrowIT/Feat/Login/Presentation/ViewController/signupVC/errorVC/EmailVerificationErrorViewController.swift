//
//  EmailVerificationErrorViewController.swift
//  GrowIT
//
//  Created by 강희정 on 1/26/25.
//

import UIKit

class EmailVerificationErrorViewController: UIViewController {
    
    let errorView = ErrorView().then {
        $0.configure(
            icon: "trashicon",
            fisrtLabel: "회원가입을 그만할까요?",
            secondLabel: "해당 화면을 나가면 처음부터 다시 진행합니다\n그래도 화면을 나갈까요?",
            firstColor: .gray900,
            secondColor: .gray700,
            title1: "나가기",
            title1Color1: .gray400,
            title1Background: .gray100,
            title2: "계속 진행하기",
            title1Color2: .white,
            title2Background: .negative400,
            targetText: "",
            viewColor: .white
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: Setup UI
    private func setupUI() {
        view.addSubview(errorView)
        errorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
        errorView.exitButton.addTarget(self, action: #selector(mainVC), for: .touchUpInside)
        errorView.continueButton.addTarget(self, action: #selector(prevVC), for: .touchUpInside)
    }
    
    // MARK: - objc
    @objc func prevVC() {
        dismiss(animated: true)
    }
    
    @objc func mainVC() {
        if let navigationController = self.presentingViewController as? UINavigationController {
            dismiss(animated: true) {
                // LoginViewController로 이동
                let loginVC = LoginViewController()
                navigationController.setViewControllers([loginVC], animated: true)
            }
        }
    }
}
