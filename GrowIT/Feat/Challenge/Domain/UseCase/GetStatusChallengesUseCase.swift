//
//  GetStatusChallengesUseCase.swift
//  GrowIT
//
//  Created by 허준호 on 7/10/25.
//

import Combine

final class GetStatusChallengesUseCase{
    private let repository: ChallengeRepository
    
    init(repository: ChallengeRepository) {
        self.repository = repository
    }
    
    func execute(type: ChallengeType, completed: Bool, page: Int) -> AnyPublisher<StatusChallenge, Error> {
        return repository.fetchChallenges(
            type: type, completed: completed, page: page
        )
    }
}

