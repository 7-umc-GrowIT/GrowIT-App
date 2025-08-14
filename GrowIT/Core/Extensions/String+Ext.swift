//
//  String+Ext.swift
//  GrowIT
//
//  Created by 이수현 on 1/30/25.
//

import Foundation

extension String {
    /// "2025-01-22" → "2025년 1월 22일" 변환
    func formattedDate() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "ko_KR")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy년 M월 d일"
        outputFormatter.locale = Locale(identifier: "ko_KR")
        
        if let date = inputFormatter.date(from: self) {
            return outputFormatter.string(from: date)
        } else {
            return self // 변환 실패 시 원본 반환
        }
    }
}
