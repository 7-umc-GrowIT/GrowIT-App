//
//  CannotChangePasswordViewController.swift
//  GrowIT
//
//  Created by 오현민 on 9/2/25.
//

import UIKit

class CannotChangePasswordViewController: UIViewController {
    private lazy var cannotChangeView = ShortageModalView().then {
        $0.config(title: "비밀번호 변경이 불가합니다", sub: "카카오 로그인 또는 애플 로그인으로 회원가입을 한 경우 앱 내 비밀번호 변경이 어려워요", icon: .growITWarning)
        $0.confirmButton.addTarget(self, action: #selector(didTapCancleButton), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view = cannotChangeView
    }

    //MARK: event
    @objc
    private func didTapCancleButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
