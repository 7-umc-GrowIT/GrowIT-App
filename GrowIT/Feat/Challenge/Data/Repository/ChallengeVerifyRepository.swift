//
//  ChallengeVerifyRepository.swift
//  GrowIT
//
//  Created by 허준호 on 7/11/25.
//

import Combine
import Foundation

protocol ChallengeVerifyRepository {
    func uploadImage(imageData: Data, fileName: String, presignedUrl: String) -> AnyPublisher<Void, Error>
    func postVerification(challengeId: Int, fileName: String, thoughts: String) -> AnyPublisher<Void, Error>
}

final class ChallengeVerifyRepositoryImpl: ChallengeVerifyRepository {
    private let dataSource: ChallengeVerifyDataSource

    init(dataSource: ChallengeVerifyDataSource) {
        self.dataSource = dataSource
    }

    func uploadImage(imageData: Data, fileName: String, presignedUrl: String) -> AnyPublisher<Void, Error> {
        dataSource.uploadImageToS3(imageData: imageData, fileName: fileName, presignedUrl: presignedUrl)
    }

    func postVerification(challengeId: Int, fileName: String, thoughts: String) -> AnyPublisher<Void, Error> {
        dataSource.postChallengeVerification(challengeId: challengeId, fileName: fileName, thoughts: thoughts)
    }
}
