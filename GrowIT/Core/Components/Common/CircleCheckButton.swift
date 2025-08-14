//
//  CircleCheckButton.swift
//  GrowIT
//
//  Created by 이수현 on 1/12/25.
//

import UIKit

class CircleCheckButton: UIButton {
    
    var isEnabledState: Bool
    
    init(isEnabled: Bool) {
        self.isEnabledState = isEnabled
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
        let tintColor: UIColor = isEnabledState ? .primary600 : .gray300
        self.setImage(UIImage(systemName: "checkmark.circle.fill")?.withTintColor(tintColor, renderingMode: .alwaysOriginal), for: .normal)
    }
    
    func isSelectedState() -> Bool {
        return isEnabledState
    }
    
    func setSelectedState(_ isSelected: Bool) {
        self.isEnabledState = isSelected
        updateButtonColor()
    }
}
