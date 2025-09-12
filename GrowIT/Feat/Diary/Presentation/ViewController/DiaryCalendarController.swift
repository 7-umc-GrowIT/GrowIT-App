//
//  TestViewController.swift
//  GrowIT
//
//  Created by 허준호 on 1/19/25.
//

import UIKit
import Then
import SnapKit

protocol DiaryCalendarControllerDelegate: AnyObject {
    func didSelectDate(_ date: String)
    
    func diaryCalendar(_ controller: DiaryCalendarController, didChangeWeekCount count: Int, _ cellWidth: Double)
}

class DiaryCalendarController: UIViewController {
    private lazy var diaryCalendar = DiaryCalendar()
    private lazy var diaryService = DiaryService()
    private lazy var callendarDiaries : [DiaryDateDTO] = []
    private var numberOfWeeksInMonth = 0  // 주 수를 저장하는 변수
    private var cellWidth: Double = 0
    private lazy var isDark: Bool = false
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    weak var delegate: DiaryCalendarControllerDelegate?
    
    var daysPerMonth: [Int] {
        return [31, isLeapYear() ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31] // 윤년 고려
    }
    let today = Calendar.current.startOfDay(for: Date())
    var currentDate = Date()
    var currentCalendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 1 // 일요일 시작
        return calendar
    }
    
    var currentMonthIndex : Int?

    var currentYear: Int?
    
    var numberOfDaysInMonth: Int {
        return daysPerMonth[currentMonthIndex!]
    }
    
    var firstWeekdayOfMonth: Int {
        var components = DateComponents()
        components.year = currentYear
        components.month = currentMonthIndex! + 1
        components.day = 1
        
        let calendar = Calendar.current
        let date = calendar.date(from: components)!
        return calendar.component(.weekday, from: date)
    }
    
    private let isDropDown: Bool
    
    init(isDropDown: Bool){
        self.isDropDown = isDropDown
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDiaryDates()
        diaryCalendar.calendarCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = diaryCalendar
        view.backgroundColor = .clear
        
        setupNotifications()
        
        currentMonthIndex = currentCalendar.component(.month, from: currentDate) - 1
        currentYear = currentCalendar.component(.year, from: currentDate)
        
        diaryCalendar.calendarCollectionView.delegate = self
        diaryCalendar.calendarCollectionView.dataSource = self
        
        diaryCalendar.todayBtn.addTarget(self, action: #selector(todayBtnTapped), for: .touchUpInside)
        diaryCalendar.backMonthBtn.addTarget(self, action: #selector(backMonthTapped), for: .touchUpInside)
        diaryCalendar.nextMonthBtn.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDiary), name: .diaryReloadNotification, object: nil)
    }
    
    func refreshData(){
        getDiaryDates()
        
    }
    
    private func getDiaryDates(){
        diaryService.fetchDiaryDates(year: currentYear!, month: currentMonthIndex! + 1, completion: { [weak self] result in
            guard let self = self else {return}
            switch result{
            case.success(let data):
                self.callendarDiaries.removeAll()
                data?.diaryDateList.forEach{
                    self.callendarDiaries.append($0)
                }
                self.updateCalendar()
            case.failure(let error):
                print("Error: \(error)")
            }
        })
    }
    
    func configureTheme(isDarkMode: Bool) {
        if isDarkMode {
            isDark = true
            diaryCalendar.onDarkMode()
        } else {
            isDark = false
        }
    }
    
    @objc private func refreshDiary() {
        refreshData()
    }
    
    @objc private func todayBtnTapped() {
        // 오늘 날짜를 currentDate에 설정
        currentDate = Date()

        // 현재 캘린더를 사용하여 현재 월과 년도를 업데이트
        currentMonthIndex = currentCalendar.component(.month, from: currentDate) - 1
        currentYear = currentCalendar.component(.year, from: currentDate)

        // 캘린더를 업데이트하여 변경된 날짜를 반영
        updateCalendar()
        getDiaryDates()
    }
    
    @objc private func backMonthTapped() {
        if currentMonthIndex == 0 {
            currentMonthIndex = 11 // 12월로 설정
            currentYear! -= 1 // 연도 감소
        } else {
            currentMonthIndex! -= 1
        }
        updateCalendar()
        getDiaryDates()
    }
    
    @objc private func nextMonthTapped() {
        let todayYear = currentCalendar.component(.year, from: today)
        let todayMonth = currentCalendar.component(.month, from: today)
        
        // 오늘 연도/월을 넘으면 return
        if (currentYear! > todayYear) ||
           (currentYear! == todayYear && currentMonthIndex! + 1 >= todayMonth) {
            return
        }

        if currentMonthIndex == 11 {
            currentMonthIndex = 0 // 1월로 설정
            currentYear! += 1 // 연도 증가
        } else {
            currentMonthIndex! += 1
        }
        updateCalendar()
        getDiaryDates()
    }
    
    private func updateCalendar() {
        diaryCalendar.yearMonthLabel.text = "\(currentYear!)년 \(currentMonthIndex! + 1)월"
        calculateWeeksInMonth()
        delegate?.diaryCalendar(self, didChangeWeekCount: numberOfWeeksInMonth, cellWidth)
        adjustCalendarHeightBasedOnWeeks()
        diaryCalendar.calendarCollectionView.reloadData()
        self.view.layoutIfNeeded()
        
        // ✅ 이번 달이면 next 버튼 숨기기
        let todayYear = currentCalendar.component(.year, from: today)
        let todayMonth = currentCalendar.component(.month, from: today)
        
        if currentYear == todayYear, currentMonthIndex! + 1 == todayMonth {
            diaryCalendar.nextMonthBtn.isHidden = true
        } else {
            diaryCalendar.nextMonthBtn.isHidden = false
        }
    }
    
    func isLeapYear() -> Bool { //윤달 계산
        let year = currentCalendar.component(.year, from: currentDate)
        return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
    }
    
    private func calculateWeeksInMonth() {
        let daysInMonth = numberOfDaysInMonth
        let daysToShowFromPrevMonth = (firstWeekdayOfMonth - currentCalendar.firstWeekday + 7) % 7
        let totalDays = daysToShowFromPrevMonth + daysInMonth
        numberOfWeeksInMonth = (totalDays + 6) / 7  // 계산된 총 일수를 7로 나누어 주 수 계산
    }

    private func adjustCalendarHeightBasedOnWeeks() {
        let totalHeight = CGFloat(numberOfWeeksInMonth) * cellWidth + 92
        diaryCalendar.calendarBg.snp.updateConstraints { make in
            make.height.equalTo(totalHeight)
        }
        view.layoutIfNeeded()  // 즉시 레이아웃을 업데이트하여 변경 사항 적용
    }
    
    
}

extension DiaryCalendarController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        let firstDayOfMonth = firstWeekdayOfMonth // 현재월의 시작
        let daysToShowFromPrevMonth = (firstDayOfMonth - currentCalendar.firstWeekday + 7) % 7
        
        let daysInMonth = numberOfDaysInMonth
        let totalDays = daysToShowFromPrevMonth + daysInMonth
        
        let extraDaysToShow = 7 - totalDays % 7
        return totalDays + (extraDaysToShow == 7 ? 0 : extraDaysToShow)  // 다음 달의 추가 날짜
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JDiaryCell.identifier, for: indexPath) as? JDiaryCell else { return UICollectionViewCell()}
        let firstDayIndex = firstWeekdayOfMonth - 1  // 0-based index
        let day = indexPath.item - firstDayIndex + 1
        
        let daysInPreviousMonth = daysPerMonth[(currentMonthIndex! + 11) % 12] // 이전 달의 날짜 수
        let previousMonthDay = daysInPreviousMonth + day
        
        let previousMonth = currentMonthIndex! == 0 ? 12 : currentMonthIndex!
        let nextMonth = currentMonthIndex! == 11 ? 1 : currentMonthIndex! + 2
        let yearAdjustmentPrevious = currentMonthIndex! == 0 ? -1 : 0
        let yearAdjustmentNext = currentMonthIndex! == 11 ? 1 : 0

        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = currentMonthIndex! + 1
        dateComponents.day = day

        // Adjust day number based on the first day of the month
        if day < 1 {
            // 이전 달의 날짜를 표시
            cell.figure(day: previousMonthDay, isSunday: false, isFromCurrentMonth: false, isDark: self.isDark)
            cell.isHidden = false
            
            dateComponents.month = previousMonth
            dateComponents.year! += yearAdjustmentPrevious
            dateComponents.day = daysPerMonth[previousMonth - 1] + day + 1
        } else if day > numberOfDaysInMonth {
            // 다음 달의 날짜를 표시
            cell.figure(day: day - numberOfDaysInMonth, isSunday: false, isFromCurrentMonth: false, isDark: self.isDark)
            cell.isHidden = false
            
            dateComponents.month = nextMonth
            dateComponents.year! += yearAdjustmentNext
            dateComponents.day = day - numberOfDaysInMonth + 1
        } else {
            // 날짜 계산
            dateComponents.day = day + 1
            
            // 현재 달의 날짜를 표시
            
            let weekdayIndex = (firstDayIndex + day - 1) % 7
            if weekdayIndex == 0 { // 일요일
                cell.figure(day: day, isSunday: true, isFromCurrentMonth: true, isDark: self.isDark)
            } else {
                cell.figure(day: day, isSunday: false, isFromCurrentMonth: true, isDark: self.isDark)
            }
            cell.isHidden = false
        }
        
        let date = currentCalendar.date(from: dateComponents)!
            let dateString = dateFormatter.string(from: date)
        
        if let _ = callendarDiaries.first(where: { $0.date == dateString }) {
            print(dateString)
            cell.showIcon(isShow: true) // 해당 날짜에 일기가 있다면 아이콘 표시
        }else {
            cell.showIcon(isShow: false)// 아니면 숨김
        }
        
        
        return cell
    }
    
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let paddingSpace = 16 * 2 // 좌우 패딩
        let availableWidth = collectionView.frame.width
        let widthPerItem = availableWidth / 7
        cellWidth = widthPerItem
    
        return CGSize(width: widthPerItem, height: widthPerItem) // 셀의 너비와 높이를 동일하게 설정
    }
    
    /// 섹션 여백
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // 섹션의 여백 설정
    }
    /// 줄 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0 // 줄 간의 간격
    }
    /// 셀 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0 // 항목 간 간격
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Unexpected element kind")
        }
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: WeekDayHeaderView.reuseIdentifier, for: indexPath) as! WeekDayHeaderView
        
        header.configureTheme(isDarkMode: self.isDark)
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 32) // 적절한 헤더 높이 설정
    }
    
    /// 셀 선택 시 실행되는 메소드
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let firstDayIndex = firstWeekdayOfMonth - 1  // 월의 첫 요일 인덱스 계산
        let day = indexPath.item - firstDayIndex + 1
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // 날짜 형식 지정
        
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        
        // 달력에서 셀의 날짜 계산
        if day < 1 {
            // 이전 달
            dateComponents.month = currentMonthIndex == 0 ? 12 : currentMonthIndex
            let daysInPreviousMonth = daysPerMonth[(currentMonthIndex! + 11) % 12]
            dateComponents.day = daysInPreviousMonth + day
            dateComponents.year! -= currentMonthIndex == 0 ? 1 : 0
        } else if day > numberOfDaysInMonth {
            // 다음 달
            dateComponents.month = currentMonthIndex == 11 ? 1 : currentMonthIndex! + 2
            dateComponents.day = day - numberOfDaysInMonth
            dateComponents.year! += currentMonthIndex == 11 ? 1 : 0
        } else {
            // 현재 달
            dateComponents.month = currentMonthIndex! + 1
            dateComponents.day = day
        }
        

        if let date = Calendar.current.date(from: dateComponents) {
            let formattedDate = dateFormatter.string(from: date)
            let today = Calendar.current.startOfDay(for: Date())
            let selectedDay = Calendar.current.startOfDay(for: date)
            
            if(selectedDay > today) {
                CustomToast(containerWidth: 277).show(image: UIImage(named: "toastAlertIcon") ?? UIImage(), message: "해당 날짜는 작성이 불가능해요", font: .heading3SemiBold())
                return
            }
            
            if let result = callendarDiaries.first(where: {$0.date == formattedDate}){
                if(self.isDropDown){
                    CustomToast(containerWidth: 310).show(image: UIImage(named: "toastAlertIcon") ?? UIImage(), message: "해당 날짜는 이미 일기를 작성했어요", font: .heading3SemiBold())
                    return
                } else{
                    diaryService.fetchDiary(diaryId: result.diaryId, completion: { [weak self] result in
                        guard let self = self else {return}
                        switch result{
                        case.success(let data):
                            print("받은 일기 데이터는 \(data)")
                            let diaryPostFixVC = DiaryPostFixViewController(text: data.content, date: data.date, diaryId: data.diaryId)
                            presentSheet(diaryPostFixVC, heightRatio: 0.6)
                        case.failure(let error):
                            print("Error: \(error)")
                        }
                    })
                    return
                }
            }
            delegate?.didSelectDate(formattedDate)
        }
    }
    
}

extension Notification.Name {
    static let deleteDiary = Notification.Name("deleteDiary")
}
