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
        useLargeOnly: Bool = false,
        minHeight: CGFloat? = nil,    // 최소 높이 옵션
        fixedHeight: CGFloat? = nil   // 고정 높이 옵션 추가
    ) {
        viewController.modalPresentationStyle = .pageSheet
            
        if let sheet = viewController.sheetPresentationController {
            if #available(iOS 16.0, *) {
                if useLargeOnly {
                    sheet.detents = [.large()]
                } else {
                    let screenHeight = UIScreen.main.bounds.height
                    let calculatedHeight = fixedHeight ?? (screenHeight * heightRatio)
                    
                    // minHeight가 지정되었다면 그 이상으로 보장
                    let finalHeight: CGFloat
                    if let minHeight = minHeight {
                        finalHeight = max(minHeight, calculatedHeight)
                    } else {
                        finalHeight = calculatedHeight
                    }
                    
                    // 화면의 95%를 넘지 않도록 제한
                    let maxHeight = screenHeight * 0.95
                    let constrainedHeight = min(finalHeight, maxHeight)
                    
                    sheet.detents = [
                        .custom { _ in constrainedHeight },
                        .large()
                    ]
                }
            } else {
                sheet.detents = [.medium(), .large()]
            }
            
            if #available(iOS 15.0, *) {
                sheet.preferredCornerRadius = 40
            }
            
            sheet.delegate = self
            sheet.prefersGrabberVisible = false
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.largestUndimmedDetentIdentifier = nil
        }
        
        present(viewController, animated: true, completion: nil)
    }
}
