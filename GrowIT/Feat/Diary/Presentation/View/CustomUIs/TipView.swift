//
//  TipView.swift
//  GrowIT
//
//  Created by 이수현 on 1/14/25.
//

import UIKit

class TipView: UIView {

    override func draw(_ rect: CGRect) {
        backgroundColor = .clear
        UIColor(hex: "#00000099")?.setFill()
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.close()
        path.fill()
    }

}
