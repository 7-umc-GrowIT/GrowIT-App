//
//  UIViewController+Ext.swift
//  GrowIT
//
//  Created by 이수현 on 1/20/25.
//

import UIKit

extension UIViewController {
    func presentPageSheet(
        viewController: UIViewController,
        detentFraction: CGFloat = 0.5,
        grabberVisible: Bool = true,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        viewController.modalPresentationStyle = .pageSheet
        
        if let sheet = viewController.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .custom { context in
                        detentFraction * context.maximumDetentValue
                    }
                ]
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = grabberVisible
        }
        
        present(viewController, animated: animated, completion: completion)
    }
}
