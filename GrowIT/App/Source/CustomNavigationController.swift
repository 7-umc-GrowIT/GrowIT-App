//
//  CustomNavigationController.swift
//  GrowIT
//
//  Created by 허준호 on 2/20/25.
//

import UIKit

class CustomNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 네비게이션 컨트롤러 내 모든 화면에서 스와이프 동작을 비활성화
        self.interactivePopGestureRecognizer?.isEnabled = false
        self.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
        // 푸시 후에도 스와이프 비활성화 유지
        self.interactivePopGestureRecognizer?.isEnabled = false
    }
}
