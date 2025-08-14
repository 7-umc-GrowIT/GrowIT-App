//
//  ChallengeDeleteModalController.swift
//  GrowIT
//
//  Created by 허준호 on 1/24/25.
//

import UIKit

extension Notification.Name {
    static let challengeDidDelete = Notification.Name("challengeDidDeleteNotification")
}

class ChallengeDeleteModalController: UIViewController {
    private lazy var challengeDeleteModal = ChallengeDeleteModal()
    private lazy var challengeService = ChallengeService()
    var challengeId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = challengeDeleteModal
        view.backgroundColor = .white
    
        challengeDeleteModal.exitBtn.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        challengeDeleteModal.deleteBtn.addTarget(self, action: #selector(deleteBtnTapped), for: .touchUpInside)
    }
    
    /// 모달 내리기
    @objc private func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 삭제 버튼 터치 이벤트
    @objc private func deleteBtnTapped() {
        deleteChallenge()
    }
    
    /// 챌린지 삭제 API
    private func deleteChallenge(){
        if let id = challengeId{
            challengeService.deleteChallenge(challengeId: id, completion:{ [weak self] result in
                guard let self = self else {return}
                switch result{
                case.success(let data):
                    NotificationCenter.default.post(name: .challengeStatusReload, object: nil)
                    CustomToast().show(image: UIImage(named: "toasttrash") ?? UIImage(), message: "챌린지를 삭제했어요", font: .heading3SemiBold())
                    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                case.failure(let error):
                    print("Error: \(error)")
                }
            })
        }
    }

}

extension Notification.Name {
    static let challengeStatusReload = Notification.Name("challengeStatusReload")
}
