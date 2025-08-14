//
//  DiaryAllView.swift
//  GrowIT
//
//  Created by 이수현 on 1/24/25.
//

import UIKit
import DropDown

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
    
    private let dropDownButton = UIButton().then {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월"
        let currentDate = dateFormatter.string(from: Date())
        
        $0.setTitle("\(currentDate) ▼", for: .normal)
        $0.titleLabel?.font = .heading2Bold()
        $0.setTitleColor(.gray900, for: .normal)
        $0.backgroundColor = .clear
        $0.contentHorizontalAlignment = .left
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
        dateView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(109)
        }
        
        dateView.addSubview(dayLabel)
        dayLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(32)
        }
        
        dateView.addSubview(dropDownButton)
        dropDownButton.snp.makeConstraints { make in
            make.leading.equalTo(dayLabel.snp.leading)
            make.top.equalTo(dayLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        addSubview(diaryCountLabel)
        diaryCountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalTo(dateView.snp.bottom).offset(16)
        }
        
        addSubview(diaryTableView)
        diaryTableView.snp.makeConstraints { make in
            make.leading.equalTo(diaryCountLabel.snp.leading)
            make.top.equalTo(diaryCountLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-53)
        }
    }
    
    private func setupDropDown() {
        dropDown.dataSource = ["2024년 10월", "2024년 11월", "2024년 12월", "2025년 1월", "2025년 2월", "2025년 3월"]
        dropDown.dismissMode = .automatic
        dropDown.backgroundColor = .gray50
        dropDown.textColor = .black
        dropDown.cornerRadius = 12
        dropDown.anchorView = dropDownButton
        
        dropDown.selectionAction = { [weak self] index, item in
            self?.dropDownButton.setTitle("\(item) ▼", for: .normal)
            
            let components = item.split(separator: " ")
            if let year = Int(components[0].replacingOccurrences(of: "년", with: "")),
               let month = Int(components[1].replacingOccurrences(of: "월", with: "")) {
                
                self?.selectedYear = year
                self?.selectedMonth = month
                
                self?.onDateSelected?(year, month)
            }
        }
        
        dropDown.customCellConfiguration = { [weak self] (index: Int, item: String, cell: DropDownCell) -> Void in
            guard let self = self else { return }
            
            let separator = UIView()
            separator.backgroundColor = .lightGray
            
            cell.addSubview(separator)
            
            separator.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(0.5)
                make.bottom.equalToSuperview()
            }
        }
        
        dropDownButton.addTarget(self, action: #selector(showDropDown), for: .touchUpInside)
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
