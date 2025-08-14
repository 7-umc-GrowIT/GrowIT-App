//
//  Font+Ext.swift
//  GrowIT
//
//  Created by 허준호 on 8/11/25.
//

import SwiftUI

struct AppTextStyle {
    let font: Font
    let kerning: CGFloat
    let lineSpacing: CGFloat
    
    // Title 1 Font
    static let title1Bold = AppTextStyle(
        font: .custom(AppFontName.pBold, size: 28),
        kerning: -28 * 0.04,
        lineSpacing: 1.2
    )
    
    // Heading 1 Bold Font
    static let heading1Bold = AppTextStyle(
        font: .custom(AppFontName.pBold, size: 24),
        kerning: -24 * 0.04,
        lineSpacing: 1.2
    )
    
    // Heading 1 SemiBold Font
    static let heading1SemiBold = AppTextStyle(
        font: .custom(AppFontName.pSemiBold, size: 24),
        kerning: -24 * 0.04,
        lineSpacing: 1.2
    )
    
    // Heading 2 Bold Font
    static let heading2Bold = AppTextStyle(
        font: .custom(AppFontName.pBold, size: 22),
        kerning: -22 * 0.04,
        lineSpacing: 1.2
    )
    
    // Heading 2 SemiBold Font
    static let heading2SemiBold = AppTextStyle(
        font: .custom(AppFontName.pSemiBold, size: 22),
        kerning: -22 * 0.04,
        lineSpacing: 1.2
    )
    
    // Heading 3 Bold Font
    static let heading3Bold = AppTextStyle(
        font: .custom(AppFontName.pBold, size: 18),
        kerning: -18 * 0.04,
        lineSpacing: 1.2
    )
    
    // Heading 3 SemiBold Font
    static let heading3SemiBold = AppTextStyle(
        font: .custom(AppFontName.pSemiBold, size: 18),
        kerning: -18 * 0.04,
        lineSpacing: 1.2
    )
    
    // Heading 3 Medium Font
    static let heading3Medium = AppTextStyle(
        font: .custom(AppFontName.pMedium, size: 18),
        kerning: -18 * 0.04,
        lineSpacing: 1.2
    )
    
    // Body 1 Medium Font
    static let body1Medium = AppTextStyle(
        font: .custom(AppFontName.pMedium, size: 16),
        kerning: -16 * 0.04,
        lineSpacing: 1.5
    )
    
    // Body 1 Regular Font
    static let body1Regular = AppTextStyle(
        font: .custom(AppFontName.pRegular, size: 16),
        kerning: -16 * 0.04,
        lineSpacing: 1.5
    )
    
    // Body 2 SemiBold Font
    static let body2SemiBold = AppTextStyle(
        font: .custom(AppFontName.pSemiBold, size: 14),
        kerning: -14 * 0.04,
        lineSpacing: 1.5
    )
    
    // Body 2 Medium Font
    static let body2Medium = AppTextStyle(
        font: .custom(AppFontName.pMedium, size: 14),
        kerning: -14 * 0.04,
        lineSpacing: 1.5
    )
    
    // Body 2 Regular Font
    static let body2Regular = AppTextStyle(
        font: .custom(AppFontName.pRegular, size: 14),
        kerning: -14 * 0.04,
        lineSpacing: 1.5
    )
    
    // Detail 1 Medium Font
    static let detail1Medium = AppTextStyle(
        font: .custom(AppFontName.pMedium, size: 12),
        kerning: -12 * 0.04,
        lineSpacing: 1.2
    )
    
    // Detail 1 Regular Font
    static let detail1Regular = AppTextStyle(
        font: .custom(AppFontName.pRegular, size: 12),
        kerning: -12 * 0.04,
        lineSpacing: 1.5
    )
    
    // Detail 2 Regular Font
    static let detail2Regular = AppTextStyle(
        font: .custom(AppFontName.pRegular, size: 11),
        kerning: -11 * 0.04,
        lineSpacing: 1.5
    )
    
    // Sub Title 1 Font
    static let subTitle1 = AppTextStyle(
        font: .custom(AppFontName.sExtraBold, size: 28),
        kerning: -28 * 0.04,
        lineSpacing: 1.5
    )
    
    // Sub Heading1 Font
    static let subHeading1 = AppTextStyle(
        font: .custom(AppFontName.sExtraBold, size: 24),
        kerning: -24 * 0.04,
        lineSpacing: 1.5
    )
    
    // Sub Heading2 Font
    static let subHeading2 = AppTextStyle(
        font: .custom(AppFontName.sExtraBold, size: 22),
        kerning: -22 * 0.04,
        lineSpacing: 1.5
    )
    
    // Sub Body 1 Font
    static let subBody1 = AppTextStyle(
        font: .custom(AppFontName.pBold, size: 14),
        kerning: -14 * 0.04,
        lineSpacing: 1.5
    )
}

/// styled 메서드로 폰트 사용 가능
/* 샘플 -> Text("완벽한 타이포그래피")
    .styled(.heading1Bold)
    .foregroundStyle(.primary)*/
extension Text {
    func styled(_ style: AppTextStyle) -> some View {
        self
            .font(style.font)
            .kerning(style.kerning)
            .lineSpacing(style.lineSpacing)
    }
}
