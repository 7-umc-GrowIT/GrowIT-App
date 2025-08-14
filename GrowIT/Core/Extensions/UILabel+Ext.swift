//
//  UILabel+Ext.swift
//  GrowIT
//
//  Created by 이수현 on 1/13/25.
//

import UIKit

extension UILabel {
    /// 텍스트의 특정 부분의 색상과 크기를 변경
    /// - Parameters:
    ///   - text: 전체 텍스트
    ///   - targetText: 스타일을 변경할 대상 텍스트
    ///   - color: 변경할 텍스트 색상
    ///   - font: 변경할 텍스트 폰트
    func setPartialTextStyle(text: String, targetText: String, color: UIColor, font: UIFont) {
        let attributedString = NSMutableAttributedString(string: text)
        
        if let range = text.range(of: targetText) {
            let nsRange = NSRange(range, in: text)
            attributedString.addAttributes(
                [
                    .foregroundColor: color,
                    .font: font
                ],
                range: nsRange
            )
        }
        
        self.attributedText = attributedString
    }
}

