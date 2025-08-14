//
//  ChallengeVerifyViewModel.swift
//  GrowIT
//
//  Created by 허준호 on 7/11/25.
//

import Combine
import UIKit

final class ChallengeVerifyViewModel: ObservableObject {
    @Published var reviewText: String = ""
    @Published var image: UIImage? = nil
    
    @Published private(set) var isReviewValid: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var showImageToast: Bool = false
    @Published private(set) var isButtonEnabled: Bool = false
    @Published private(set) var success: Bool = false
    
    private let useCase: ChallengeVerifyUseCase
    let challenge: UserChallenge?
    private var cancellables = Set<AnyCancellable>()
    
    // 플레이스홀더인지 상태 저장(옵셔널)
    var isPlaceholder: Bool = true
    
    static let placeholder = "챌린지 소감을 간단하게 입력해 주세요"
    
    init(challenge: UserChallenge?, useCase: ChallengeVerifyUseCase) {
        self.challenge = challenge
        self.useCase = useCase
        
        $reviewText
            .sink { [weak self] text in
                let count = text.count
                // 실시간으론 에러메시지 만지지 않음!
                if count == 0 {
                    self?.isReviewValid = false
                    self?.isButtonEnabled = false
                } else if count < 50 || count > 100 {
                    self?.isReviewValid = false
                    self?.isButtonEnabled = false
                } else {
                    self?.isReviewValid = true
                    self?.isButtonEnabled = (self?.image != nil)
                }
            }.store(in: &cancellables)
        
        $image
            .sink { [weak self] img in
                if let self = self {
                    self.isButtonEnabled = self.isReviewValid && (img != nil)
                }
            }
            .store(in: &cancellables)
    }
    
    /// 완료(리턴) 누를 때만 호출
    func validateReviewText() {
        let count = reviewText.count
        if count == 0 {
            errorMessage = nil // 입력이 아예 없으면 에러 아님 (플레이스홀더)
        } else if count < 50 || count > 100 {
            errorMessage = "챌린지 한줄소감을 50자 이상 100자 이하로 입력해 주세요"
        } else {
            errorMessage = nil
        }
    }
    
    func resetErrorMessage() {
        errorMessage = nil
    }
    
    func verify() {
        // 이미지 없으면 토스트
        guard let image = image, let imageData = image.pngData() else {
            showImageToast = true
            return
        }
        guard isReviewValid else { return }
        // API 요청 (UseCase)
        useCase.verifyChallenge(
            challengeId: challenge!.id,
            imageData: imageData,
            thoughts: reviewText
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.errorMessage = error.localizedDescription
            }
        } receiveValue: { [weak self] _ in
            self?.success = true
        }
        .store(in: &cancellables)
    }
}

