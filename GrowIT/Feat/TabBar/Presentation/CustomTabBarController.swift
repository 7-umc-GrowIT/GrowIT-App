//
//  CustomTabBarController.swift
//  GrowIT
//
//  Created by 허준호 on 1/9/25.
//

import UIKit
import SnapKit

class CustomTabBarController: UIViewController, UINavigationControllerDelegate {
    
    var customTabBar: CustomTabBarView!
    private var viewControllers: [UIViewController] = []
    private var initialViewControllerIndex: Int = 1
        
    init(initialIndex: Int) {
        self.initialViewControllerIndex = initialIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switchTo(index: initialViewControllerIndex)
        customTabBar.updateTabItemSelection(at: initialViewControllerIndex)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupCustomTabBar()
        
        navigationController?.navigationBar.isHidden = true
        
    }
    
    private func setupViewControllers() {
        let firstVC = DiaryHomeViewController()
        let secondVC = HomeViewController()
        let thirdVC = ChallengeHomeViewController()
        
        
        // 각 뷰 컨트롤러를 UINavigationController에 포함시킵니다.
        let firstNavController = UINavigationController(rootViewController: firstVC)
        let secondNavController = UINavigationController(rootViewController: secondVC)
        let thirdNavController = UINavigationController(rootViewController: thirdVC)
        
        firstNavController.delegate = self
        secondNavController.delegate = self
        thirdNavController.delegate = self

           // 네비게이션 컨트롤러 배열을 viewControllers에 할당
        viewControllers = [firstNavController, secondNavController, thirdNavController]

           // 초기 뷰 컨트롤러 설정
        add(asChildViewController: viewControllers[initialViewControllerIndex])
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count > 1 {
            self.customTabBar.isHidden = true
        } else {
            self.customTabBar.isHidden = false
        }
    }
    
    private func setupCustomTabBar() {
        customTabBar = CustomTabBarView()
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customTabBar)
        customTabBar.didSelectItem = { [weak self] index in
            self?.switchTo(index: index)
            self?.customTabBar.updateTabItemSelection(at: index)
        }
        
        customTabBar.snp.makeConstraints{
            $0.bottom.horizontalEdges.equalToSuperview()
            $0.height.equalTo(154)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(customTabBar)
    }
    
    private func switchTo(index: Int) {
        let newVC = viewControllers[index]
        if children.last == newVC { return }
        replaceChildViewController(with: newVC)
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        addChild(viewController)
        view.insertSubview(viewController.view, at: 0)
        viewController.view.frame = view.bounds
        viewController.didMove(toParent: self)
    }
    
    private func replaceChildViewController(with newViewController: UIViewController) {
        let currentViewController = children.last
        addChild(newViewController)
        
        transition(from: currentViewController!, to: newViewController, duration: 0.3, options: .transitionCrossDissolve, animations: {
            newViewController.view.frame = self.view.bounds
        }) { [weak self] completed in
            currentViewController?.willMove(toParent: nil)
            currentViewController?.view.removeFromSuperview()
            currentViewController?.removeFromParent()
            newViewController.didMove(toParent: self)
        }
    }
}
