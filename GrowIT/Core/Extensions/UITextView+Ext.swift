//
//  UITextView+Ext.swift
//  GrowIT
//
//  Created by 이수현 on 2/18/25.
//

import UIKit

extension UITextView {
    func setLineSpacing(spacing: CGFloat, font: UIFont, color: UIColor) {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = spacing
        
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: style,
            .font: font, // 사용 중인 폰트
            .foregroundColor: color // 텍스트 색상
        ]
        
        self.attributedText = NSAttributedString(string: self.text ?? "", attributes: attributes)
    }
}
