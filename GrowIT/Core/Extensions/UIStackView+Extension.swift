//
//  UIStackView+Extension.swift
//  GrowIT
//
//  Created by 오현민 on 1/8/25.
//

import UIKit

extension UIStackView {
    func addArrangedSubViews(_ views: [UIView]) {
        for view in views {
            self.addArrangedSubview(view)
        }
    }
}
