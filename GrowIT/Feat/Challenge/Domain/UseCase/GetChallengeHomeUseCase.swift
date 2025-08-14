//
//  GetChallengeHomeUseCase.swift
//  GrowIT
//
//  Created by 허준호 on 6/5/25.
//

import Combine

protocol GetChallengeHomeUseCase {
    func execute() -> AnyPublisher<ChallengeHomeResponseDTO, Error>
}

final class GetChallengeHomeUseCaseImpl: GetChallengeHomeUseCase {
    private let repository: ChallengeRepository

    init(repository: ChallengeRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<ChallengeHomeResponseDTO, Error> {
        return repository.fetchChallengeHome()
    }
}

