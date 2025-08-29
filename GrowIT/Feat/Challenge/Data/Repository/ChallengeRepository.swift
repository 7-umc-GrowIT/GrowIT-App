//
//  ChallengeRepositoryImpl.swift
//  GrowIT
//
//  Created by 허준호 on 6/5/25.
//

import Combine

protocol ChallengeRepository {
    func fetchChallengeHome() -> AnyPublisher<ChallengeHomeResponseDTO, Error>
    
    func fetchChallenges(type: ChallengeType, completed: Bool, page: Int) -> AnyPublisher<StatusChallenge, Error>
}

final class ChallengeRepositoryImpl: ChallengeRepository {
    private let dataSource: ChallengeDataSource
    
    init(dataSource: ChallengeDataSource) {
        self.dataSource = dataSource
    }
    
    func fetchChallengeHome() -> AnyPublisher<ChallengeHomeResponseDTO, Error> {
        return dataSource.fetchChallengeHome()
    }
    
    func fetchChallenges(type: ChallengeType, completed: Bool, page: Int) -> AnyPublisher<StatusChallenge, Error> {
        dataSource.fetchChallengeStatus(challengeType: type.rawValue, completed: "\(completed)", page: page)
            .map { dto in
                // content([UserChallengeDTO])만 순회
                let challenges = dto.content.map { UserChallenge(dto: $0) }
                // totalPages 등은 그냥 넣음
                return StatusChallenge(
                    challenge: challenges,
                    totalPages: dto.totalPages
                    // 필요한 경우 currentPage 등 추가
                )
            }
            .eraseToAnyPublisher()
    }

}
