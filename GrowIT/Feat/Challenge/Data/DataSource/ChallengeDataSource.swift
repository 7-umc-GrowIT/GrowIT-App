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
            challengeType: String,
            completed: String,
            page: Int
        ) -> AnyPublisher<ChallengeStatusResponseDTO, Error>
}

final class ChallengeDataSourceImpl: ChallengeDataSource {
    func fetchChallengeHome() -> AnyPublisher<ChallengeHomeResponseDTO, Error> {
        Future { promise in
            ChallengeService().fetchChallengeHome { result in
//                let sampleData = ChallengeHomeResponseDTO(challengeKeywords: ["피곤한", "지친", "힘든"], recommendedChallenges: [RecommendedChallengeDTO(id: 0, title: "위로되는 음악 듣기", content: "", challengeType: "DAILY", time: 60, completed: false),RecommendedChallengeDTO(id: 0, title: "좋아하는 옷 입고 외출하기", content: "", challengeType: "DAILY", time: 60, completed: false),RecommendedChallengeDTO(id: 0, title: "위로되는 음악 듣기", content: "", challengeType: "DAILY", time: 60, completed: false)], challengeReport: ChallengeReportDTO(totalCredits: 1000, totalDiaries: 10, diaryDate: "D+10"))
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
            challengeType: String,
            completed: String,
            page: Int
        ) -> AnyPublisher<ChallengeStatusResponseDTO, Error> {
            Future { promise in
                ChallengeService().fetchChallengeStatus(
                    challengeType: challengeType,
                    completed: completed,
                    page: page
                ) { result in
                    switch result {
                    case .success(let dto):
                        promise(.success(dto))
                    case .failure(let error):
                        print("챌린지 현황 조회 error: \(error)")
                        promise(.failure(error))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
}
