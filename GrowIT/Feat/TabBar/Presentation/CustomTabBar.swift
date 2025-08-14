//
//  CustomTabBar.swift
//  GrowIT
//
//  Created by 허준호 on 1/9/25.
//

import UIKit

import UIKit

class CustomTabBar: UITabBar {
    
    private let middleButton = UIButton()

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.addMiddleButton()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

       

        let numberOfItems = CGFloat(self.items?.count ?? 0)
        let tabBarButtonWidth = (self.bounds.width - 140) / numberOfItems

        var index = 0
        for subview in self.subviews where subview is UIControl {
            if index == 1 { // 중앙 버튼은 스킵
                index += 1
            }
            let xPosition = tabBarButtonWidth * CGFloat(index)
            subview.frame = CGRect(x: xPosition, y: 0, width: tabBarButtonWidth, height: self.bounds.height)
            index += 1
        }

        self.middleButton.center = CGPoint(x: self.bounds.width / 2, y: 0)
    }
    
    private func addMiddleButton() {
        middleButton.frame = CGRect(x: (self.bounds.width / 2) - 54, y: -30, width: 108, height: 108)
        middleButton.backgroundColor = UIColor.primary400
        middleButton.layer.cornerRadius = 54
        middleButton.setImage(UIImage(named: "home"), for: .normal)
        middleButton.addTarget(self, action: #selector(middleButtonAction), for: .touchUpInside)
        
        self.addSubview(middleButton)
        self.bringSubviewToFront(middleButton)
    }
    
    @objc func middleButtonAction() {
        // 중앙 버튼 클릭 시 액션 처리
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 100 // 커스텀 높이
        return sizeThatFits
    }
}

