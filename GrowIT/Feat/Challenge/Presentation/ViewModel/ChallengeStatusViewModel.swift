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
    @Published private(set) var selectedType: ChallengeType = .all
    @Published private(set) var completed: Bool = false
    @Published private(set) var page: Int = 1

    // Outputs
    @Published private(set) var challenges: [UserChallenge] = []
    @Published private(set) var totalPages: Int = 0
    @Published private(set) var totalElements: Int = 0
    @Published private(set) var error: Error?

    private let getChallengesUseCase: GetStatusChallengesUseCase
    private var cancellables = Set<AnyCancellable>()

    init(getChallengesUseCase: GetStatusChallengesUseCase) {
        self.getChallengesUseCase = getChallengesUseCase
    }

    // MARK: - 버튼별 API 호출
    func fetchChallengesForStatus(index: Int, page: Int = 1) {
        let type: ChallengeType
        let completed: Bool

        switch index {
        case 0: // 전체
            type = .all
            completed = false
        case 1: // 완료
            type = .all
            completed = true
        case 2: // 랜덤
            type = .random
            completed = false
        case 3: // 데일리
            type = .daily
            completed = false
        default:
            type = .all
            completed = false
        }

        self.selectedType = type
        self.completed = completed
        self.page = page

        getChallengesUseCase.execute(type: type, completed: completed, page: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(err) = completion {
                    self?.error = err
                }
            }, receiveValue: { [weak self] statusChallenge in
                self?.challenges = statusChallenge.challenge
                self?.totalPages = statusChallenge.totalPages
                self?.totalElements = statusChallenge.totalElements
            })
            .store(in: &cancellables)
    }

    // MARK: - 페이지 이동
    func moveToPage(_ page: Int) {
        guard page > 0 else { return }
        self.page = page
        // 현재 선택된 상태 그대로 재호출
        getChallengesUseCase.execute(type: selectedType, completed: completed, page: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(err) = completion {
                    self?.error = err
                }
            }, receiveValue: { [weak self] statusChallenge in
                self?.challenges = statusChallenge.challenge
                self?.totalPages = statusChallenge.totalPages
            })
            .store(in: &cancellables)
    }

    // MARK: - 새로고침
    func refresh() {
        getChallengesUseCase.execute(type: selectedType, completed: completed, page: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(err) = completion {
                    self?.error = err
                }
            }, receiveValue: { [weak self] statusChallenge in
                self?.challenges = statusChallenge.challenge
                self?.totalPages = statusChallenge.totalPages
            })
            .store(in: &cancellables)
    }
}


