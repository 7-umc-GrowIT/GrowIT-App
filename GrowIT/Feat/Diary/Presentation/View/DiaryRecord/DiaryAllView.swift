//
//  DiaryAllView.swift
//  GrowIT
//
//  Created by 이수현 on 1/24/25.
//

import UIKit
import DropDown
import SnapKit

class DiaryAllView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupDropDown()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dropDown.bottomOffset = CGPoint(x: 0, y: dropDownButton.frame.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var onDateSelected: ((Int, Int) -> Void)?
    
    var selectedYear: Int = Calendar.current.component(.year, from: Date())
    var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    
    // MARK: - UI Components
    
    private let dateView = UIView().then {
        $0.backgroundColor = .gray50
    }
    
    private let dayLabel = UILabel().then {
        $0.text = "나의 일기를 모아보세요!"
        $0.font = .body2SemiBold()
        $0.textColor = .primary600
    }
    
    // 추후 드롭다운으로 수정 예정
    private let dropDown = DropDown()
    
    private let dropDownStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
        $0.distribution = .fill
    }
    
    let dateLabel = UILabel().then {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월"
        let currentDate = dateFormatter.string(from: Date())
        
        $0.text = "\(currentDate)"
        $0.font = .heading2Bold()
        $0.textColor = .gray900
        $0.isUserInteractionEnabled = false
    }
    
    let dropDownButton = UIButton().then {
        $0.setImage(UIImage(named: "dropdownIcon"), for: .normal)
        $0.backgroundColor = .clear
        $0.tintColor = .gray500
        $0.isUserInteractionEnabled = false
    }

    let diaryCountLabel = UILabel().then {
        var count = 0
        let allText = "작성한 일기 수 \(count)"
        $0.text = allText
        $0.font = .body2Medium()
        $0.textColor = .gray600
        $0.setPartialTextStyle(text: allText, targetText: "\(count)", color: .primary700, font: .body2Medium())
    }
    
    let diaryTableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.register(DiaryAllViewTableViewCell.self, forCellReuseIdentifier: DiaryAllViewTableViewCell.identifier)
    }
    
    private func setupUI() {
        backgroundColor = .white
        addSubview(dateView)
        dateView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(109)
        }
        
        dateView.addSubview(dayLabel)
        dayLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(32)
        }
        
        dropDownStack.addArrangedSubview(dateLabel)
        dropDownStack.addArrangedSubview(dropDownButton)
        dateView.addSubview(dropDownStack)
        
        dropDownStack.snp.makeConstraints {
            $0.top.equalTo(dayLabel.snp.bottom).offset(8)
            $0.leading.equalTo(dayLabel.snp.leading)
        }
    
        addSubview(diaryCountLabel)
        diaryCountLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(dateView.snp.bottom).offset(16)
        }
        
        addSubview(diaryTableView)
        diaryTableView.snp.makeConstraints {
            $0.leading.equalTo(diaryCountLabel.snp.leading)
            $0.top.equalTo(diaryCountLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-53)
        }
    }
    
    private func setupDropDown() {
        // 최소 시작 연/월
        let minYear = 2025
        let minMonth = 3
        
        // 현재 연/월
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        
        // 날짜 포맷터
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        
        var dataSource: [String] = []
        
        var year = minYear
        var month = minMonth
        
        while (year < currentYear) || (year == currentYear && month <= currentMonth) {
            if let date = Calendar.current.date(from: DateComponents(year: year, month: month)) {
                dataSource.append(formatter.string(from: date))
            }
            
            // 다음 달로 이동
            month += 1
            if month > 12 {
                month = 1
                year += 1
            }
        }
        
        dropDown.dataSource = dataSource
        dropDown.dismissMode = .automatic
        dropDown.backgroundColor = .gray50
        dropDown.textColor = .black
        dropDown.cornerRadius = 12
        dropDown.anchorView = dropDownStack
        dropDown.width = UIScreen.main.bounds.width - 48
        
        dropDown.selectionAction = { [weak self] index, item in
            self?.dateLabel.text = item
            
            let components = item.split(separator: " ")
            if let year = Int(components[0].replacingOccurrences(of: "년", with: "")),
               let month = Int(components[1].replacingOccurrences(of: "월", with: "")) {
                
                self?.selectedYear = year
                self?.selectedMonth = month
                self?.onDateSelected?(year, month)
            }
        }
        
        dropDown.customCellConfiguration = { [weak self] (index: Int, item: String, cell: DropDownCell) -> Void in
            guard self != nil else { return }
            let separator = UIView()
            separator.backgroundColor = .lightGray
            cell.addSubview(separator)
            separator.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(0.5)
                $0.bottom.equalToSuperview()
            }
        }
        
        dropDownStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showDropDown)))
        dropDownStack.isUserInteractionEnabled = true
    }

    
    func updateDiaryCount(_ count: Int) {
        let allText = "작성한 일기 수 \(count)"
        diaryCountLabel.text = allText
        diaryCountLabel.setPartialTextStyle(text: allText, targetText: "\(count)", color: .primary700, font: .body2Medium())
    }
    
    @objc private func showDropDown() {
        dropDown.show()
    }
}
