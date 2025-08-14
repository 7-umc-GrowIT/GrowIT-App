//
//  AppButton.swift
//  GrowIT
//
//  Created by 이수현 on 1/11/25.
//

import UIKit
import SnapKit
import Then

class AppButton: UIButton {

    init(
        title: String = "",
        titleColor: UIColor = .black,
        isEnabled: Bool = true,
        icon: String = ""
    ) {
        super.init(frame: .zero)
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.backgroundColor = isEnabled ? UIColor.primary400 : UIColor.primary50
        self.setImage(UIImage(named: icon), for: .normal)
        
        self.titleLabel?.font = UIFont.heading2Bold()
        self.layer.cornerRadius = 16
        
        self.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setButtonState(isEnabled: Bool, enabledColor: UIColor, disabledColor: UIColor, enabledTitleColor: UIColor, disabledTitleColor: UIColor) {
        // isEnabled 값에 따라 배경색을 다르게 설정
        self.backgroundColor = isEnabled ? enabledColor : disabledColor
        self.setTitleColor(isEnabled ? enabledTitleColor : disabledTitleColor, for: .normal)
    }
    
}
