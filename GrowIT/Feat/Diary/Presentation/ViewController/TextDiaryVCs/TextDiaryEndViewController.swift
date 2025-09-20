//
//  TextDiaryEndViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/13/25.
//

import UIKit

class TextDiaryEndViewController: UIViewController {

    //MARK: - Properties
    let textDiaryEndView =  TextDiaryEndView()
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
            tintColor: .black
        )
        
        navigationBarManager.setTitle(
            to: navigationItem,
            title: "직접 일기 작성하기",
            textColor: .black
        )
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(textDiaryEndView)
        textDiaryEndView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    //MARK: - Setup Actions
    private func setupActions() {
        textDiaryEndView.nextButton.addTarget(self, action: #selector(nextVC), for: .touchUpInside)
    }
    
    //MARK: - @objc methods
    @objc func prevVC() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func nextVC() {
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else {
            return
        }
        let tabBarController = CustomTabBarController(initialIndex: 2)
        sceneDelegate.window?.rootViewController = tabBarController
        sceneDelegate.window?.makeKeyAndVisible()
    }

}
