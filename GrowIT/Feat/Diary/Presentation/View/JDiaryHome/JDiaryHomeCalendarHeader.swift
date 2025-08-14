//
//  JDiaryHomeCalendar.swift
//  GrowIT
//
//  Created by 허준호 on 1/16/25.
//

import UIKit
import Then
import SnapKit

class JDiaryHomeCalendarHeader: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addComponents()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Property
    private lazy var title = AppLabel(text: "나의 일기 기록", font: .heading1Bold(), textColor: .black)
    
    private lazy var subTitle = AppLabel(text: "날짜별로 확인하고 간단하게 확인해요", font: .body2Medium(), textColor: .gray500)
    
    lazy var collectBtn = UIButton().then{
        $0.setTitle("한 번에 모아보기", for: .normal)
        $0.setTitleColor(.gray500, for: .normal)
        $0.titleLabel?.font = .detail1Medium()
        $0.layer.cornerRadius = 16
        $0.backgroundColor = .gray100
        $0.clipsToBounds = true
    }
    
    // MARK: - addFunc & Constraints
    private func addComponents(){
        [title, subTitle, collectBtn].forEach(self.addSubview)
    }
   
    private func constraints(){
        
        title.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.left.equalToSuperview().offset(24)
        }
        
        subTitle.snp.makeConstraints{
            $0.top.equalTo(title.snp.bottom).offset(4)
            $0.left.equalToSuperview().offset(24)
        }
        
        collectBtn.snp.makeConstraints{
            $0.top.equalTo(title.snp.top)
            $0.right.equalToSuperview().inset(24)
            $0.width.equalToSuperview().multipliedBy(0.25)
            $0.height.equalTo(32)
        }
    }
}
