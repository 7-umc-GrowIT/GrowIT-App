//
//  UIView+Ext.swift
//  GrowIT
//
//  Created by 이수현 on 1/14/25.
//

import UIKit

/// 그라데이션을 설정하는 메서드 익스텐션
extension UIView {
    func setGradient(color1: UIColor, color2: UIColor) {
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [color1.cgColor, color2.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        gradient.frame = bounds
        gradient.cornerRadius = 20
        self.backgroundColor = .clear
        
        layer.insertSublayer(gradient, at: 0)
    }
}
