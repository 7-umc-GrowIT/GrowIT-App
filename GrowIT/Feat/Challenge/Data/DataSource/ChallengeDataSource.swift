//
//  ChallengeDataSource.swift
//  GrowIT
//
//  Created by 허준호 on 6/4/25.
//

import Foundation
import Combine

protocol ChallengeDataSource {
    func fetchChallengeHome() -> AnyPublisher<ChallengeHomeResponseDTO, Error>
    
    func fetchChallengeStatus(
            dtype: String,
            completed: Bool,
            page: Int
        ) -> AnyPublisher<ChallengeStatusResponseDTO, Error>
}

final class ChallengeDataSourceImpl: ChallengeDataSource {
    func fetchChallengeHome() -> AnyPublisher<ChallengeHomeResponseDTO, Error> {
        Future { promise in
            ChallengeService().fetchChallengeHome { result in
                switch result {
                case .success(let data):
                    promise(.success(data))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchChallengeStatus(
            dtype: String,
            completed: Bool,
            page: Int
        ) -> AnyPublisher<ChallengeStatusResponseDTO, Error> {
            Future { promise in
                ChallengeService().fetchChallengeStatus(
                    dtype: dtype,
                    completed: completed,
                    page: page
                ) { result in
                    switch result {
                    case .success(let dto):
                        promise(.success(dto))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
}
