//
//  ItemTabSegmentedControl.swift
//  GrowIT
//
//  Created by 오현민 on 1/10/25.
//

import UIKit

class ItemTabSegmentedControl: UISegmentedControl {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.removeBackgroundAndDivider()
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        self.removeBackgroundAndDivider()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 기능
    private func removeBackgroundAndDivider() {
        let image = UIImage()
            self.setBackgroundImage(image, for: .normal, barMetrics: .default)
            self.setBackgroundImage(image, for: .selected, barMetrics: .default)
            self.setBackgroundImage(image, for: .highlighted, barMetrics: .default)
            self.setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
    }
}
