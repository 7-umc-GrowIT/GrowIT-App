//
//  ChallengeStatusViewModel.swift
//  GrowIT
//
//  Created by 허준호 on 7/10/25.
//

import Combine
import Foundation

final class ChallengeStatusViewModel {
    // Inputs
    @Published var selectedType: ChallengeType = .all
    @Published var completed: Bool = false
    @Published var page: Int = 1

    // Outputs
    @Published private(set) var challenges: [UserChallenge] = []
    @Published private(set) var totalPages: Int = 0
    @Published private(set) var error: Error?

    private let getChallengesUseCase: GetStatusChallengesUseCase
    private var cancellables = Set<AnyCancellable>()

    init(getChallengesUseCase: GetStatusChallengesUseCase) {
        self.getChallengesUseCase = getChallengesUseCase
        bindInputs()
    }

    private func bindInputs() {
        Publishers.CombineLatest3($selectedType, $completed, $page)
            .removeDuplicates { (lhs, rhs) in
                lhs.0 == rhs.0 && lhs.1 == rhs.1 && lhs.2 == rhs.2
            }
            .sink { [weak self] type, completed, page in
                self?.fetchChallenges(type: type, completed: completed, page: page)
            }
            .store(in: &cancellables)
    }

    private func fetchChallenges(type: ChallengeType, completed: Bool, page: Int) {
        getChallengesUseCase.execute(type: type, completed: completed, page: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(err) = completion {
                    self?.error = err
                }
            }, receiveValue: { [weak self] statusChallenge in
                self?.challenges = statusChallenge.challenge // challenge 필드
                self?.totalPages = statusChallenge.totalPages // totalPages 필드
            })
            .store(in: &cancellables)
    }

    func moveToPage(_ page: Int) {
        guard page > 0 else { return }
        self.page = page
    }
    
    func refresh() {
        fetchChallenges(type: selectedType, completed: completed, page: page)
    }
}

