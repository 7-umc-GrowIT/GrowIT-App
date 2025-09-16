//
//  UIViewController+Ext.swift
//  GrowIT
//
//  Created by 이수현 on 1/20/25.
//

import UIKit

extension UIViewController: @retroactive UISheetPresentationControllerDelegate {
    func presentSheet(
        _ viewController: UIViewController,
        heightRatio: CGFloat,
        useLargeOnly: Bool = false
    ) {
        viewController.modalPresentationStyle = .pageSheet
            
        if let sheet = viewController.sheetPresentationController {
            if #available(iOS 16.0, *) {
                if useLargeOnly {
                    sheet.detents = [.large()]
                } else {
                    // 기본 높이는 custom, 사용자가 끌면 large까지 확장 가능
                    sheet.detents = [.custom { _ in UIScreen.main.bounds.height * heightRatio }, .large()]
                }
            } else {
                sheet.detents = [.medium(), .large()]
            }
            
            if #available(iOS 15.0, *) {
                sheet.preferredCornerRadius = 40
            }
            
            sheet.delegate = self
            sheet.prefersGrabberVisible = false // 사용자가 끌기 쉽게 그랩퍼를 보이도록
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true // 스크롤 시 확장 허용
        }
        
        present(viewController, animated: true, completion: nil)
    }
}
