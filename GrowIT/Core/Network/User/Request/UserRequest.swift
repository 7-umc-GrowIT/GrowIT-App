//
//  UserRequest.swift
//  GrowIT
//
//  Created by 오현민 on 1/31/25.
//

import Foundation

struct UserPostRequestDTO: Codable {
    let paymentId: String
    let amount: Int
    let creditAmount: Int
    let paymentMethod: String?
}

struct UserPatchRequestDTO: Codable {
    let isVerified: Bool
    let email: String
    let password: String
    let passwordCheck: String
}

