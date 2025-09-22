//
//  DiaryDeleteViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/24/25.
//

import UIKit

class DiaryDeleteViewController: UIViewController {
    
    var onDismiss: (() -> Void)?
    private let diaryService = DiaryService()
    private let diaryId: Int
    var isDeleting: Bool = false
    let date: String
    let today = Calendar.current.startOfDay(for: Date())
    
    let deleteView = ErrorView().then {
        $0.configure(icon: "trashIcon", fisrtLabel: "정말 일기를 삭제할까요?", secondLabel: "삭제한 일기는 복구하기 어렵습니다. 일기 재작성 시 크레딧은 추가 지급되지 않습니다.\n그래도 일기를 삭제할까요?", firstColor: .gray900, secondColor: .gray600, title1: "나가기", title1Color1: .gray400, title1Background: .gray100, title2: "삭제하기", title1Color2: .white, title2Background: .negative400, targetText: "", viewColor: .white)
    }
    
    init(diaryId: Int, date: String) {
        self.diaryId = diaryId
        self.date = date
        print("삭제하 날짜는 \(date)")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    
    private func setupUI() {
        view.addSubview(deleteView)
        deleteView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: Setup Actions
    private func setupActions() {
        deleteView.exitButton.addTarget(self, action: #selector(mainVC), for: .touchUpInside)
        deleteView.continueButton.addTarget(self, action: #selector(prevVC), for: .touchUpInside)
    }
    
    // MARK: @objc methods
    @objc func prevVC() {
        callDeleteDiary()
    }
    
    @objc func mainVC() {
        dismiss(animated: true)
    }
    
    // MARK: Setup APIs
    private func callDeleteDiary() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // 날짜 형식 지정
        let today = dateFormatter.string(from: Calendar.current.startOfDay(for: Date()))
       
        guard !isDeleting else { return }
        isDeleting = true
        diaryService.deleteDiary(
            diaryId: diaryId,
            completion: {[weak self] result in
                guard let self = self else { return }
                self.isDeleting = false
                switch result {
                case .success(let data):
                    print("Success: \(data)")
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .diaryReloadNotification, object: nil)
                        
                        if(today == self.date) {
                            NotificationCenter.default.post(name: .challengeReloadNotification, object: nil)
                        }
                        CustomToast(containerWidth: 195).show(image: UIImage(named: "toasttrash") ?? UIImage(), message: "일기를 삭제했어요", font: .heading3SemiBold())
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        )
    }
}

extension Notification.Name {
    static let diaryReloadNotification = Notification.Name("diaryReloadNotification")
}
