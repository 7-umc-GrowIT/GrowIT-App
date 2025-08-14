//
//  ChallengeViewModel.swift
//  GrowIT
//
//  Created by 허준호 on 6/5/25.
//

import Combine
import Foundation

final class ChallengeHomeViewModel: ObservableObject {
    
    @Published var todayChallenges: [RecommendedChallenge] = []
    @Published var keywords: [String] = []
    @Published var report: ChallengeReportDTO?
    
    private let getChallengeHomeUseCase: GetChallengeHomeUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(useCase: GetChallengeHomeUseCase) {
        self.getChallengeHomeUseCase = useCase
        loadData()
    }
    
    func loadData() {
        getChallengeHomeUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] response in
                    self?.updateData(with: response)
                }
            )
            .store(in: &cancellables)
    }
    
    private func updateData(with response: ChallengeHomeResponseDTO) {
        keywords = response.challengeKeywords
        todayChallenges = response.recommendedChallenges.map{ RecommendedChallenge(dto: $0)}
        report = response.challengeReport
    }
    
    private func handleError(_ error: Error) {
        // 로그 기록 (실제 앱에서는 로깅 라이브러리 사용)
        print("ChallengeHomeViewModel Error: \(error)")
    }
    
    func refresh() {
        loadData()
    }
}
