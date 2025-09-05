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
                sheet.detents = useLargeOnly ? [.large()] : [.custom { _ in UIScreen.main.bounds.height * heightRatio }]
            } else {
                sheet.detents = [.medium(), .large()]
            }
            
            if #available(iOS 15.0, *) {
                sheet.preferredCornerRadius = 40
            }
            
            sheet.delegate = self
            sheet.prefersGrabberVisible = false
            sheet.selectedDetentIdentifier = .large
        }
        
        present(viewController, animated: true, completion: nil)
    }
}
