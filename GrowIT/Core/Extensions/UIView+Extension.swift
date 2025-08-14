//
//  UIView+Extension.swift
//  GrowIT
//
//  Created by 오현민 on 1/8/25.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }
}
