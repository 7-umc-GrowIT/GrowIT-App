//
//  VoiceDiaryTipViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/18/25.
//

import UIKit

class VoiceDiaryTipViewController: UIViewController {
    
    // MARK: Properties
    let errorView = VoiceDiaryTipView()
    
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
    
    // MARK: Setup Actions
    private func setupActions() {
        errorView.exitButton.addTarget(self, action: #selector(prevVC), for: .touchUpInside)
    }
    
    // MARK: @objc methods
    @objc func prevVC() {
        dismiss(animated: true)
    }
    
}
