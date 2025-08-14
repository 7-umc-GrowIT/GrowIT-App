//
//  JDiaryHomeNavbar.swift
//  GrowIT
//
//  Created by 허준호 on 1/14/25.
//

import UIKit
import Then
import SnapKit

class JDiaryHomeNavbar: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addComponents()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Property
    
    private lazy var titleLabel = UILabel().then{
        $0.text = "일기"
        $0.textColor = .grayColor900
        $0.font = .title1Bold()
    }
    
    private lazy var settingBtn = UIImageView().then {
        $0.image = UIImage(named: "setting")
        $0.contentMode = .scaleAspectFit
    }
    
    // MARK: - addFunction & Constraints
    
    private func addComponents(){
        [titleLabel, settingBtn].forEach(self.addSubview)
    }
    
    private func constraints(){
        
        titleLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(24)
        }
        
        settingBtn.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(24)
            $0.height.width.equalTo(34)
        }
    }
}
