//
//  JDiaryHomeCalendar.swift
//  GrowIT
//
//  Created by 허준호 on 1/16/25.
//

import UIKit
import Then
import SnapKit

class DiaryHomeCalendarHeader: UIView {
    
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
    
    let allViewContainer = UIView().then {
        $0.backgroundColor = .gray100
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }
    
    let allViewText = UILabel().then {
        $0.text = "한 번에 모아보기"
        $0.font = .detail1Medium()
        $0.textColor = .gray400
        $0.adjustsFontSizeToFitWidth = true
    }
    
    // MARK: - addFunc & Constraints
    private func addComponents(){
        [title, subTitle, allViewContainer].forEach(self.addSubview)
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
        
        allViewContainer.addSubview(allViewText)
        
        allViewContainer.snp.makeConstraints{
            $0.top.equalTo(title.snp.top)
            $0.right.equalToSuperview().inset(24)
            $0.width.equalToSuperview().multipliedBy(0.25)
            $0.height.equalTo(32)
        }
        
        allViewText.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(7)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }
}
