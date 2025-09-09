//
//  AccountInquiryErrorViewController.swift
//  GrowIT
//
//  Created by 허준호 on 9/7/25.
//

import UIKit

class AccountInquiryViewController: UIViewController {
    
    private let accountInquiryModalView = AccountInquiryModalView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view = accountInquiryModalView
        
        accountInquiryModalView.confirmBtn.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
    }
    
    @objc private func confirmTapped() {
        self.dismiss(animated: true)
    } 
    
    public func setDarkMode() {
        accountInquiryModalView.setDark()
    }
}
