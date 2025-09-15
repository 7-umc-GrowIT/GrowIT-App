//
//  TipView.swift
//  GrowIT
//
//  Created by 이수현 on 1/14/25.
//

import UIKit

class TipView: UIView {
    enum Direction {
        case up, down, left, right
    }
    
    private let direction: Direction
    
    init(direction: Direction) {
        self.direction = direction
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        UIColor(hex: "#00000099")?.setFill()
        
        let path = UIBezierPath()
        
        switch direction {
        case .down:
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.maxX, y: 0))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        case .up:
            path.move(to: CGPoint(x: 0, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: 0))
        case .left:
            path.move(to: CGPoint(x: rect.maxX, y: 0))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: 0, y: rect.midY))
        case .right:
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
        
        path.close()
        path.fill()
    }
}
