//
//  AppLabel.swift
//  GrowIT
//
//  Created by 허준호 on 1/16/25.
//

import UIKit

class AppLabel: UILabel {
    // 텍스트, 폰트, 텍스트 색상을 매개변수로 받는 초기화 메소드
    convenience init(text: String, font: UIFont, textColor: UIColor) {
        self.init(frame: .zero)  // frame을 .zero로 설정하여 오토 레이아웃에 사용하기 용이하게 함
        self.text = text
        self.font = font
        self.textColor = textColor
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

