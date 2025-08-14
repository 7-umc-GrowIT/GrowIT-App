//
//  ChallengeVerifyDataSource.swift
//  GrowIT
//
//  Created by 허준호 on 7/11/25.
//

import Combine
import UIKit

protocol ChallengeVerifyDataSource {
    func uploadImageToS3(imageData: Data, fileName: String, presignedUrl: String) -> AnyPublisher<Void, Error>
    func getPresignedUrl(fileName: String) -> AnyPublisher<String, Error>
    func getS3ImageUrl(fileName: String) -> AnyPublisher<String, Error>
    func postChallengeVerification(challengeId: Int, imageUrl: String, thoughts: String) -> AnyPublisher<Void, Error>
}

final class ChallengeVerifyDataSourceImpl: ChallengeVerifyDataSource {
    func uploadImageToS3(imageData: Data, fileName: String, presignedUrl: String) -> AnyPublisher<Void, Error> {
        var request = URLRequest(url: URL(string: presignedUrl)!)
        request.httpMethod = "PUT"
        request.setValue("image/png", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData

        return Future<Void, Error> { promise in
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    promise(.failure(error))
                } else if let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200 {
                    promise(.success(()))
                } else {
                    promise(.failure(NSError(domain: "UploadFailed", code: -1)))
                }
            }
            task.resume()
        }.eraseToAnyPublisher()
    }

    func getPresignedUrl(fileName: String) -> AnyPublisher<String, Error> {
        // S3Service를 Combine으로 래핑
        Future { promise in
            S3Service().putS3UploadUrl(fileName: fileName, completion: { result in
                switch result {
                case .success(let data):
                    promise(.success(data.presignedUrl))
                case .failure(let error):
                    promise(.failure(error))
                }
            })
        }.eraseToAnyPublisher()
    }

    func getS3ImageUrl(fileName: String) -> AnyPublisher<String, Error> {
        Future { promise in
            S3Service().getS3DownloadUrl(fileName: fileName, completion: { result in
                switch result {
                case .success(let data):
                    let url = data.components(separatedBy: "?").first ?? data
                    promise(.success(url))
                case .failure(let error):
                    promise(.failure(error))
                }
            })
        }.eraseToAnyPublisher()
    }

    func postChallengeVerification(challengeId: Int, imageUrl: String, thoughts: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            ChallengeService().postProveChallenge(
                challengeId: challengeId,
                data: ChallengeRequestDTO(certificationImageUrl: imageUrl, thoughts: thoughts),
                completion: { result in
                    switch result {
                    case .success:
                        promise(.success(()))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            )
        }.eraseToAnyPublisher()
    }
}
