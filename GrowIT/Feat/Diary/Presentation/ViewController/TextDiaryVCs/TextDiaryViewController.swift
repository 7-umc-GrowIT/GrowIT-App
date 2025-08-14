//
//  TextDiaryViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/12/25.
//

import UIKit
import EzPopup

class TextDiaryViewController: UIViewController, JDiaryCalendarControllerDelegate {
    
    //MARK: - Properties
    let navigationBarManager = NavigationManager()
    let textDiaryView = TextDiaryView()
    let diaryService = DiaryService()
    
    let calVC = JDiaryCalendarController(isDropDown: true)
    
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
        textDiaryView.dropDownButton.addTarget(self, action: #selector(calenderVC), for: .touchUpInside)
    }
    
    //MARK: - @objc methods
    @objc func prevVC() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func nextVC() {
        print(textDiaryView.saveButton.isEnabled)
        if textDiaryView.saveButton.isEnabled == false {
            CustomToast(containerWidth: 232).show(image: UIImage(named: "toast_Icon") ?? UIImage(), message: "일기를 더 작성해 주세요", font: .heading3SemiBold())
        } else {
            let userDiary = textDiaryView.diaryTextField.text ?? ""
            let date = textDiaryView.dateLabel.text ?? ""
            
            let nextVC = TextDiaryLoadingViewController()
            nextVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(nextVC, animated: true)
            
            callPostTextDiary(userDiary: userDiary, date: date) { diaryId in
                DispatchQueue.main.async {
                    nextVC.navigateToNextScreen(with: diaryId)
                }
            }
        }
    }
    
    @objc func calenderVC(_ sender: UIButton) {
        let calVC = JDiaryCalendarController(isDropDown: true)
        calVC.configureTheme(isDarkMode: false)
        calVC.delegate = self
        calVC.view.backgroundColor = .clear
        let popupVC = PopupViewController(contentController: calVC, popupWidth: 382, popupHeight: 370)
        present(popupVC, animated: true)
    }
    
    func didSelectDate(_ date: String) {
        textDiaryView.updateDateLabel(date)
        
        if let presentedVC = self.presentedViewController {
            presentedVC.dismiss(animated: true)
        }
    }
    
    // MARK: Setup APIs
    func callPostTextDiary(userDiary: String, date: String, completion: @escaping (Int) -> Void) {
        let convertedDate = convertDateFormat(from: date)
        UserDefaults.standard.set(convertedDate, forKey: "TextDate")
        diaryService.postTextDiary(
            data: DiaryRequestDTO(
                content: userDiary,
                date: convertedDate ?? ""),
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case.success(let data):
                    DispatchQueue.main.async {
                        completion(data.diaryId)
                    }
                case.failure(let error):
                    print("Error")
                }
            }
        )
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
