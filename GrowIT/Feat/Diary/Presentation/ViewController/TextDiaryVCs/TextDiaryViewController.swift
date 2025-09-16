//
//  TextDiaryViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/12/25.
//

import UIKit
import EzPopup

class TextDiaryViewController: UIViewController, DiaryCalendarControllerDelegate, UIGestureRecognizerDelegate {
    
    
    //MARK: - Properties
    let navigationBarManager = NavigationManager()
    let textDiaryView = TextDiaryView()
    let diaryService = DiaryService()
    let calVC = DiaryCalendarController(isDropDown: true)
    var isSaving: Bool = false
    
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
        textDiaryView.dropDownStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCalendarOverlay))
        )
    }
    
    //MARK: - @objc methods
    @objc func prevVC() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func nextVC() {
        if (textDiaryView.dateLabel.text == "날짜를 선택해주세요") {
            showCalendarOverlay()
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
    
    @objc private func showCalendarOverlay() {
        // 이미 올라와 있으면 중복 방지
        if view.viewWithTag(999) != nil { return }

        // 1) dimmed background
        let dimmedView = UIView()
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        dimmedView.alpha = 0
        dimmedView.tag = 999
        view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 2) 캘린더 VC 재사용 (property calVC)
        calVC.configureTheme(isDarkMode: false)
        calVC.delegate = self

        addChild(calVC)
        dimmedView.addSubview(calVC.view)
        calVC.didMove(toParent: self)

        calVC.view.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(382)
            $0.height.equalTo(370) // 필요하면 동적으로 업데이트 가능
        }
        calVC.view.layer.cornerRadius = 12
        calVC.view.clipsToBounds = true
        calVC.view.isUserInteractionEnabled = true

        // 3) dimmedView 탭 제스처: 캘린더 내부의 터치는 무시하도록 delegate 사용
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideCalendarOverlay))
        tapGesture.cancelsTouchesInView = false           // 중요: 터치가 하위뷰로 전달되도록 기본 차단 해제
        tapGesture.delegate = self                         // 아래 delegate 메서드로 캘린더 내부 터치 무시
        dimmedView.addGestureRecognizer(tapGesture)

        // show animation
        UIView.animate(withDuration: 0.25) {
            dimmedView.alpha = 1
        }
    }
    
    @objc func hideCalendarOverlay() {
        guard let dimmedView = view.viewWithTag(999) else { return }

        UIView.animate(withDuration: 0.22, animations: {
            dimmedView.alpha = 0
        }, completion: { _ in
            // 캘린더 child 정리
            self.calVC.willMove(toParent: nil)
            self.calVC.view.removeFromSuperview()
            self.calVC.removeFromParent()

            dimmedView.removeFromSuperview()
        })
    }
    
    @objc(gestureRecognizer:shouldReceiveTouch:) func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 만약 터치된 뷰가 calVC.view(또는 그 하위뷰)이면, 제스처가 처리하지 않음(캘린더가 터치를 받도록)
        if let touchedView = touch.view, touchedView.isDescendant(of: calVC.view) {
            return false
        }
        return true
    }
    
    @objc func popUp(_ sender: UIButton) {
        popUpCalendar()
    }
    
    private func popUpCalendar() {
        let calVC = DiaryCalendarController(isDropDown: true)
        calVC.configureTheme(isDarkMode: false)
        calVC.delegate = self
        calVC.view.backgroundColor = .clear
        
        let popupVC = PopupViewController(contentController: calVC, popupWidth: 382, popupHeight: 370)
        
        present(popupVC, animated: true)
    }
    
    func didSelectDate(_ date: String) {
        textDiaryView.updateDateLabel(date)
        hideCalendarOverlay()
    }
    
    func diaryCalendar(_ controller: DiaryCalendarController, didChangeWeekCount count: Int, _ cellWidth: Double) {
        let extraHeight: CGFloat = 88
        let totalHeight = CGFloat(count) * cellWidth + extraHeight
        
        calVC.view.snp.updateConstraints() {
            $0.height.equalTo(totalHeight) 
        }
    }
    
    // MARK: Setup APIs
    func callPostTextDiary(userDiary: String, date: String, completion: @escaping (Int) -> Void) {
        guard !isSaving else { return }
        isSaving = true
        let convertedDate = convertDateFormat(from: date)
        UserDefaults.standard.set(convertedDate, forKey: "TextDate")
        diaryService.postTextDiary(
            data: DiaryRequestDTO(
                content: userDiary,
                date: convertedDate ?? "")
        ){ result in
            self.isSaving = false
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
