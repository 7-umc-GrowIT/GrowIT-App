//
//  JDiaryCalendar.swift
//  GrowIT
//
//  Created by 허준호 on 1/16/25.
//

import UIKit
import Then
import SnapKit

class JDiaryCalendar: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addStack()
        addComponents()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Property
    // 달력 배경 박스
    public lazy var calendarBg = UIView().then{
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
    }
    
    // 이전 월 이동 버튼
    public lazy var backMonthBtn = UIButton().then{
        $0.setImage(UIImage(named: "jMonthBack"), for: .normal)
        $0.contentMode = .scaleAspectFit
    }
    
    // 년월 표시 라벨
    public lazy var yearMonthLabel = AppLabel(text: "2025년 1월", font: .subBody1(), textColor: .gray600)
    
    // 다음 월 이동 버튼
    public lazy var nextMonthBtn = UIButton().then{
        $0.setImage(UIImage(named: "jMonthNext"), for: .normal)
        $0.contentMode = .scaleAspectFit
    }
    
    // 오늘로 이동하는 버튼
    public lazy var todayBtn = UIButton().then{
        $0.setTitle("오늘", for: .normal)
        $0.setTitleColor(.gray600, for: .normal)
        $0.titleLabel?.font = .subBody1()
    }
    
    // 날짜 컬렉션뷰
    public lazy var calendarCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then{
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
        $0.itemSize = CGSize(width: 52, height: 52)
    }).then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.register(JDiaryCell.self, forCellWithReuseIdentifier: JDiaryCell.identifier)
        $0.register(JWeekDayHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: JWeekDayHeaderView.reuseIdentifier)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Stack
    private lazy var yearMonthHeader = makeStack(axis: .horizontal, spacing: 10)
    
    // MARK: - Func
    private func makeStack(axis: NSLayoutConstraint.Axis, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.distribution = .equalSpacing
        return stackView
    }
    
    public func onDarkMode(){
        self.calendarBg.backgroundColor = .gray700
        self.backMonthBtn.tintColor = .gray500
        self.nextMonthBtn.tintColor = .gray500
        self.yearMonthLabel.textColor = .gray300
        self.todayBtn.setTitleColor(.gray300, for: .normal)
    }
   
    // MARK: - addFunc & Constraints
    private func addStack(){
        [backMonthBtn, yearMonthLabel, nextMonthBtn].forEach(yearMonthHeader.addArrangedSubview)
    }
    
    private func addComponents(){
        addSubview(calendarBg)
        [yearMonthHeader, todayBtn, calendarCollectionView].forEach(calendarBg.addSubview)
    }
    
    private func constraints(){
        
        calendarBg.snp.makeConstraints{
            $0.top.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(366)
        }
        
        yearMonthHeader.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.left.equalToSuperview().offset(16)
            $0.height.equalTo(32)
        }
        
        backMonthBtn.snp.makeConstraints{
            $0.width.height.equalTo(24)
        }
        
        nextMonthBtn.snp.makeConstraints{
            $0.height.width.equalTo(24)
        }
        
        todayBtn.snp.makeConstraints{
            $0.top.equalTo(yearMonthHeader.snp.top)
            $0.right.equalToSuperview().inset(24)
        }
        
        calendarCollectionView.snp.makeConstraints {
            $0.top.equalTo(yearMonthHeader.snp.bottom).offset(6)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(12)
        }
    }
    

}
