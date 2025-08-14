//
//  VoiceDiaryEndViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/16/25.
//

import UIKit

class VoiceDiaryEndViewController: UIViewController {

    //MARK: - Properties
    let voiceDiaryEndView =  VoiceDiaryEndView()
    let navigationBarManager = NavigationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupActions()
        setupNavigationBar()
    }
    
    //MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        navigationBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(prevVC),
            tintColor: .white
        )
        
        navigationBarManager.setTitle(
            to: navigationItem,
            title: "",
            textColor: .white
        )
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(voiceDiaryEndView)
        voiceDiaryEndView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    //MARK: - Setup Actions
    private func setupActions() {
        voiceDiaryEndView.nextButton.addTarget(self, action: #selector(nextVC), for: .touchUpInside)
    }
    
    //MARK: - @objc methods
    @objc func prevVC() {
        // navigationController?.popViewController(animated: true)
    }
    
    @objc func nextVC() {
        let nextVC = CustomTabBarController(initialIndex: 2)
        navigationController?.pushViewController(nextVC, animated: false)
    }

    
}
