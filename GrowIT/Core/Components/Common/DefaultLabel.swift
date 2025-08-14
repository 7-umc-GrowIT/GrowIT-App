//
//  DefaultLabel.swift
//  GrowIT
//
//  Created by 허준호 on 8/11/25.
//

import SwiftUI

// MARK: - 기본 텍스트 라벨(SwiftUI)
struct DefaultLabel: View {
    let title: String
    let color: Color
    let font: AppTextStyle
    
    var body: some View {
        Text(title)
            .foregroundColor(color)
            .styled(font)
    }
}
