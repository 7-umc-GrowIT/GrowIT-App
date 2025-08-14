//
//  Int+Ext.swift
//  GrowIT
//
//  Created by 허준호 on 2/12/25.
//

extension Int {
    var formattedTime: String {
        if self == 0 {
            return "해당 없음"
        } else if self % 60 == 0 {
            return "\(self / 60)시간"
        } else if self / 60 == 0 {
            return "\(self % 60)분"
        } else {
            return "\(self / 60)시간 \(self % 60)분"
        }
    }
}
