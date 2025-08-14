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
    func getPresignedUrl(fileName: String) -> AnyPublisher<String, Error>
    func getS3ImageUrl(fileName: String) -> AnyPublisher<String, Error>
    func postVerification(challengeId: Int, imageUrl: String, thoughts: String) -> AnyPublisher<Void, Error>
}

final class ChallengeVerifyRepositoryImpl: ChallengeVerifyRepository {
    private let dataSource: ChallengeVerifyDataSource

    init(dataSource: ChallengeVerifyDataSource) {
        self.dataSource = dataSource
    }

    func uploadImage(imageData: Data, fileName: String, presignedUrl: String) -> AnyPublisher<Void, Error> {
        dataSource.uploadImageToS3(imageData: imageData, fileName: fileName, presignedUrl: presignedUrl)
    }

    func getPresignedUrl(fileName: String) -> AnyPublisher<String, Error> {
        dataSource.getPresignedUrl(fileName: fileName)
    }

    func getS3ImageUrl(fileName: String) -> AnyPublisher<String, Error> {
        dataSource.getS3ImageUrl(fileName: fileName)
    }

    func postVerification(challengeId: Int, imageUrl: String, thoughts: String) -> AnyPublisher<Void, Error> {
        dataSource.postChallengeVerification(challengeId: challengeId, imageUrl: imageUrl, thoughts: thoughts)
    }
}
