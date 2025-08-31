//
//  FriendReadyModalViewViewController.swift
//  GrowIT
//
//  Created by 허준호 on 8/31/25.
//

import UIKit

class FriendReadyModalViewController: UIViewController {
    
    private let friendReadyModal = FriendReadyModalView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = friendReadyModal
        view.backgroundColor = .white
        
        friendReadyModal.checkButton.addTarget(self, action: #selector(checkBtnTapped), for: .touchUpInside)
    }
    
    @objc private func checkBtnTapped() {
        self.dismiss(animated: true)
    }
}
