//
//  TextDiaryViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/12/25.
//

import UIKit
import EzPopup

class TextDiaryViewController: UIViewController, DiaryCalendarControllerDelegate {
    
    
    //MARK: - Properties
    let navigationBarManager = NavigationManager()
    let textDiaryView = TextDiaryView()
    let diaryService = DiaryService()
    let calVC = DiaryCalendarController(isDropDown: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupActions()
        navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        navigationBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(prevVC),
            tintColor: .black
        )
        
        navigationBarManager.setTitle(
            to: navigationItem,
            title: "직접 일기 작성하기",
            textColor: .black
        )
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(textDiaryView)
        textDiaryView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    //MARK: - Setup Button actions
    private func setupActions() {
        textDiaryView.saveButton.addTarget(self, action: #selector(nextVC), for: .touchUpInside)
        textDiaryView.dropDownStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(popUp))
        )
    }
    
    //MARK: - @objc methods
    @objc func prevVC() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func nextVC() {
        print(textDiaryView.saveButton.backgroundColor == .black)
        if (textDiaryView.dateLabel.text == "날짜를 선택해주세요") {
            popUpCalendar()
        } else if(textDiaryView.saveButton.backgroundColor != .black) {
            CustomToast(containerWidth: 232).show(image: UIImage(named: "toastIcon") ?? UIImage(), message: "일기를 더 작성해 주세요", font: .heading3SemiBold())
        } else {
            let userDiary = textDiaryView.diaryTextField.text ?? ""
            let date = textDiaryView.dateLabel.text ?? ""
            
            callPostTextDiary(userDiary: userDiary, date: date) { diaryId in
                let nextVC = TextDiaryLoadingViewController(diaryId: diaryId)
                nextVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }
    }
    
    @objc func popUp(_ sender: UIButton) {
        popUpCalendar()
    }
    
    private func popUpCalendar() {
        let calVC = DiaryCalendarController(isDropDown: true)
        calVC.configureTheme(isDarkMode: false)
        calVC.delegate = self
        calVC.view.backgroundColor = .clear
        let totalHeight = calVC.view.bounds.height
        let popupVC = PopupViewController(contentController: calVC, popupWidth: 382, popupHeight: 370)
        present(popupVC, animated: true)
    }
    
    func didSelectDate(_ date: String) {
        textDiaryView.updateDateLabel(date)
        
        if let presentedVC = self.presentedViewController {
            presentedVC.dismiss(animated: true)
        }
    }
    
    func diaryCalendar(_ controller: DiaryCalendarController, didChangeWeekCount count: Int, _ cellWidth: Double) {
        let baseHeightPerWeek: CGFloat = 52 // 주당 높이 설정 예시
        let extraHeight: CGFloat = 92       // 기존에 더한 높이
        print(cellWidth)
        let totalHeight = CGFloat(count) * cellWidth + extraHeight

        calVC.view.snp.updateConstraints { make in
            make.height.equalTo(totalHeight)
        }

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Setup APIs
    func callPostTextDiary(userDiary: String, date: String, completion: @escaping (Int) -> Void) {
        let convertedDate = convertDateFormat(from: date)
        UserDefaults.standard.set(convertedDate, forKey: "TextDate")
        diaryService.postTextDiary(
            data: DiaryRequestDTO(
                content: userDiary,
                date: convertedDate ?? "")
        ){ result in
            switch result {
            case .success(let data):
                completion(data.diaryId)
            case .failure:
                print("직접 작성한 일기 저장 실패")
            }
        }
    }
    
    func convertDateFormat(from originalDate: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy년 M월 d일"
        inputFormatter.locale = Locale(identifier: "ko_KR")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"

        if let date = inputFormatter.date(from: originalDate) {
            return outputFormatter.string(from: date)
        } else {
            return nil
        }
    }
}
