//
//  UserChallenge.swift
//  GrowIT
//
//  Created by 허준호 on 7/10/25.
//

struct UserChallenge {
    let id: Int
    let title: String
    let type: ChallengeType
    let time: Int
    let completed: Bool
}

enum ChallengeType: String {
    case all = ""      // 전체 조회
    case random = "RANDOM"
    case daily = "DAILY"
    
    // dto -> Domain 변환
    init(dto: String) {
        switch dto {
        case "RANDOM": self = .random
        case "DAILY": self = .daily
        default: self = .all
        }
    }
}

extension UserChallenge {
    init(dto: UserChallengeDto) {
        self.id = dto.id
        self.title = dto.title
        self.type = ChallengeType(dto: dto.dtype)
        self.time = dto.time
        self.completed = dto.completed
    }
}
