//
//  JWeekDayHeaderView.swift
//  GrowIT
//
//  Created by 허준호 on 1/19/25.
//

import UIKit
import SnapKit

class JWeekDayHeaderView: UICollectionReusableView {

    static let reuseIdentifier = "WeekdayHeaderView"
    private var dayLabels: [UILabel] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWeekdayLabels()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupWeekdayLabels() {
        let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        //stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        stackView.snp.makeConstraints{
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(12)
        }
        
        daysOfWeek.forEach { day in
            var label = UILabel()
            if(day == "일"){
                label = AppLabel(text: day, font: .subBody1(), textColor: .negative400)
                label.textAlignment = .center
            }else{
                label = AppLabel(text: day, font: .subBody1(), textColor: .gray600)
            }
            label.textAlignment = .center
            dayLabels.append(label)
            stackView.addArrangedSubview(label)
        }
    }
    
    func configureTheme(isDarkMode: Bool) {
        dayLabels.enumerated().forEach { index, label in
            if isDarkMode {
                label.textColor = index == 0 ? .negative400 : .gray300
            } else {
                label.textColor = index == 0 ? .negative400 : .gray600
            }
        }
    }

}
