//
//  WithdrawModalViewController.swift
//  GrowIT
//
//  Created by 오현민 on 7/16/25.
//

import UIKit

class WithdrawModalViewController: UIViewController {
    //MARK: -Views
    private lazy var withdrawModalView = WithdrawModalView().then {
        $0.cancleButton.addTarget(self, action: #selector(didTapCancleButton), for: .touchUpInside)
        $0.withDrawButton.addTarget(self, action: #selector(didTapWithDraw), for: .touchUpInside)
    }
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = withdrawModalView
    }

    //MARK: - Functional
    //MARK: Event
    @objc private func didTapWithDraw(){
        let nextVC = WithdrawViewController()
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc
    private func didTapCancleButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
