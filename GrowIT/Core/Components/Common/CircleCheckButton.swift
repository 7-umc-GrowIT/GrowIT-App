//
//  CircleCheckButton.swift
//  GrowIT
//
//  Created by 이수현 on 1/12/25.
//

import UIKit

class CircleCheckButton: UIButton {
    
    var isEnabledState: Bool
    var size: CGFloat
    
    init(isEnabled: Bool, size: CGFloat) {
        self.isEnabledState = isEnabled
        self.size = size
        super.init(frame: .zero)

        updateButtonColor()
        self.addTarget(self, action: #selector(toggleState), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func toggleState() {
        isEnabledState = !isEnabledState
        updateButtonColor()
    }
    
    func updateButtonColor() {
        if(isEnabledState) {
            let resizedImage = UIImage(named: "check-selected")?.resized(to: CGSize(width: size, height: size))
            self.setImage(resizedImage, for: .normal)
            self.imageView?.contentMode = .scaleAspectFit
            self.configuration = nil
        }else {
            let resizedImage = UIImage(named: "check")?.resized(to: CGSize(width: size, height: size))
            self.setImage(resizedImage, for: .normal)
            self.imageView?.contentMode = .scaleAspectFit
            self.configuration = nil
        }
    }
    
    func isSelectedState() -> Bool {
        return isEnabledState
    }
    
    func setSelectedState(_ isSelected: Bool) {
        self.isEnabledState = isSelected
        updateButtonColor()
    }
}
