//
//  ChallengeVerifyModalController.swift
//  GrowIT
//
//  Created by 허준호 on 1/24/25.
//

import UIKit


protocol ChallengeVerifyModalDelegate: AnyObject {
    func didRequestVerification()
}

class ChallengeVerifyModalController: UIViewController {
    weak var delegate: ChallengeVerifyModalDelegate?
    var challengeId: Int?
    
    private lazy var challengeVerifyModal = ChallengeVerifyModal()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = challengeVerifyModal
        view.backgroundColor = .white

        challengeVerifyModal.exitBtn.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        challengeVerifyModal.deleteBtn.addTarget(self, action: #selector(deleteBtnTapped), for: .touchUpInside)
        challengeVerifyModal.verifyBtn.addTarget(self, action: #selector(verifyBtnTapped), for: .touchUpInside)
    }
    
    @objc private func deleteBtnTapped() {
        let nextVC = ChallengeDeleteModalController()
        //print("인증모달에서 id 출력: \(challengeId)")
        if let id = challengeId{
            nextVC.challengeId = id
        }
        nextVC.modalPresentationStyle = .pageSheet
        
        presentSheet(nextVC, heightRatio: 0.32)
    }
    
    @objc private func dismissModal() {
        self.dismiss(animated: true, completion: nil) // 챌린지 인증 바텀모달 해제
    }
    
    @objc private func verifyBtnTapped() {
        print("인증버튼 클릭됨")
        self.dismiss(animated: true) {
            self.delegate?.didRequestVerification() // 챌린지 인증 바텀모달 해제 후 챌린지 인증화면으로 이동
        }
    }

}


extension Notification.Name {
    static let closeModalAndMoveVC = Notification.Name("closeModalAndMoveVC")
}
