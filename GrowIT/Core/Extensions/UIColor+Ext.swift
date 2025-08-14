//
//  UIColor+Ext.swift
//  GrowIT
//
//  Created by 허준호 on 1/6/25.
//
import UIKit

extension UIColor{
    
    // View에서 사용할때는 UIColor.변수명으로 사용하면 되고,
    // 만약 cgColor 써야되는 속성이면 UIColor.변수명!.cgColor로 써야됩니다. 반드시 ! 붙이세요
    
    ///Primary Colors
    static let primaryColor50 = UIColor(named: "Primary-50")
    static let primaryColor100 = UIColor(named: "Primary-100")
    static let primaryColor200 = UIColor(named: "Primary-200")
    static let primaryColor300 = UIColor(named: "Primary-300")
    static let primaryColor400 = UIColor(named: "Primary-400")
    static let primaryColor500 = UIColor(named: "Primary-500")
    static let primaryColor600 = UIColor(named: "Primary-600")
    static let primaryColor700 = UIColor(named: "Primary-700")
    static let primaryColor800 = UIColor(named: "Primary-800")
    static let primaryColor900 = UIColor(named: "Primary-900")
    
    
    ///Gray Colors
    static let grayColor50 = UIColor(named: "Gray-50")
    static let grayColor100 = UIColor(named: "Gray-100")
    static let grayColor200 = UIColor(named: "Gray-200")
    static let grayColor300 = UIColor(named: "Gray-300")
    static let grayColor400 = UIColor(named: "Gray-400")
    static let grayColor500 = UIColor(named: "Gray-500")
    static let grayColor600 = UIColor(named: "Gray-600")
    static let grayColor700 = UIColor(named: "Gray-700")
    static let grayColor800 = UIColor(named: "Gray-800")
    static let grayColor900 = UIColor(named: "Gray-900")
    
    
    ///Semantic Colors
    ///Negative Colors
    static let negativeColor50 = UIColor(named: "Negative-50")
    static let negativeColor100 = UIColor(named: "Negative-100")
    static let negativeColor400 = UIColor(named: "Negative-400")
    
    ///Positive Colors
    static let positiveColor50 = UIColor(named: "Positive-50")
    static let positiveColor100 = UIColor(named: "Positive-100")
    static let positiveColor400 = UIColor(named: "Positive-400")
    
    ///Item Colors
    static let itemColorYellow = UIColor(named: "Item-Yellow")
    static let itemColorGreen = UIColor(named: "Item-Green")
    static let itemColorPink = UIColor(named: "Item-Pink")

    ///Stroke Colors
    static let stroke2 = UIColor(named: "border-2")
    
    /// HEX 문자열을 UIColor로 변환하는 초기화 메서드
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let length = hexSanitized.count
        
        let r, g, b, a: CGFloat
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
