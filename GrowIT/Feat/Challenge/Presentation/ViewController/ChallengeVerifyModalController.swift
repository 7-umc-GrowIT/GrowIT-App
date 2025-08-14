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
        
        if let sheet = nextVC.sheetPresentationController {
                    
            //지원할 크기 지정
            if #available(iOS 16.0, *){
                sheet.detents = [
                    .custom{ _ in
                    314.0
                }]
            }else{
                sheet.detents = [.medium(), .large()]
            }
            
            // 시트의 상단 둥근 모서리 설정
            if #available(iOS 15.0, *) {
                sheet.preferredCornerRadius = 40
            }
            
            //크기 변하는거 감지
            sheet.delegate = self
           
            //시트 상단에 그래버 표시 (기본 값은 false)
            sheet.prefersGrabberVisible = false
        }
        
        self.present(nextVC, animated: true, completion: nil) //챌린지 삭제 바텀모달 이동
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

extension ChallengeVerifyModalController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        //크기 변경 됐을 경우
        print(sheetPresentationController.selectedDetentIdentifier == .large ? "large" : "medium")
    }
}

extension Notification.Name {
    static let closeModalAndMoveVC = Notification.Name("closeModalAndMoveVC")
}
