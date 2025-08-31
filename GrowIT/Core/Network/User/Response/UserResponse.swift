//
//  UserResponse.swift
//  GrowIT
//
//  Created by 오현민 on 1/31/25.
//

import Foundation

struct UserPostResponseDTO: Decodable {
    let currentCredit, totalCredit: Int
    let status, paidAt: String
}

struct UserPatchResponseDTO: Decodable { // 비밀번호 변경 API
    let isSuccess: Bool
    let code: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case isSuccess = "isSuccess"
        case code = "code"
        case message = "message"
    }
}

struct EmptyResult: Decodable {} // 비밀번호 변경 API


struct UserGetCreditResponseDTO: Decodable {
    let currentCredit: Int
}

struct UserGetTotalCreditResponseDTO: Decodable {
    let totalCredit: Int
}

struct UserGetMypageResponseDTO: Decodable {
    let userId: Int
    let name: String
}

struct UserDeleteResponseDTO: Decodable { }
