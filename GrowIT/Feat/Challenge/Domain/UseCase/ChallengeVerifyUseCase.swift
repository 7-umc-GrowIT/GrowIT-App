////
////  ChallengeVerifyUseCase.swift
////  GrowIT
////
////  Created by 허준호 on 7/11/25.
////
//
//import Combine
//import Foundation
//
//protocol ChallengeVerifyUseCase {
//    func verifyChallenge(challengeId: Int, imageData: Data, thoughts: String) -> AnyPublisher<Void, Error>
//}
//
//final class ChallengeVerifyUseCaseImpl: ChallengeVerifyUseCase {
//    private let repository: ChallengeVerifyRepository
//
//    init(repository: ChallengeVerifyRepository) {
//        self.repository = repository
//    }
//
//    func verifyChallenge(challengeId: Int, imageData: Data, thoughts: String) -> AnyPublisher<Void, Error> {
//        let fileName = "\(UUID().uuidString).png"
//        // Presigned URL → S3 Upload → S3 ImageUrl → 인증API 순으로 체인
//        return repository.getPresignedUrl(fileName: fileName)
//            .flatMap { presignedUrl in
//                self.repository.uploadImage(imageData: imageData, fileName: fileName, presignedUrl: presignedUrl)
//                    .map { presignedUrl }
//            }
//            .flatMap { _ in
//                self.repository.getS3ImageUrl(fileName: fileName)
//            }
//            .flatMap { fileName in
//                self.repository.postVerification(challengeId: challengeId, fileName: fileName, thoughts: thoughts)
//            }
//            .eraseToAnyPublisher()
//    }
//}
