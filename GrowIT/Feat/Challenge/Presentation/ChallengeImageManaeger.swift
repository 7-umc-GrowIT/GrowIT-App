//
//  ChallengeImageManager.swift
//  GrowIT
//
//  Created by 허준호 on 2/14/25.
//

import Foundation

class ChallengeImageManager {
    let challengeService = ChallengeService()
    var imageData: Data?
    
    init(imageData: Data? = nil) {
        self.imageData = imageData
    }
    
    /// 이미지 업로드 및 업로드된 파일 이름 반환
    func uploadImage(completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = imageData else {
            completion(.failure(NSError(
                domain: "ImageManagerError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Image data is nil"]
            )))
            return
        }
        
        // 1. Presigned URL 요청
        challengeService.postPresignedUrl(
            data: PresignedUrlRequestDTO(contentType: "image/png"),
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    // 2. Presigned URL로 S3에 업로드
                    self.putImageToS3(
                        presignedUrl: data.presignedUrl,
                        imageData: imageData,
                        fileName: data.fileName
                    ) { result in
                        switch result {
                        case .success:
                            // 3. 성공 시 fileName 반환
                            completion(.success(data.fileName))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    print("Presigned URL 요청 에러: \(error)")
                    completion(.failure(error))
                }
            }
        )
    }
    
    /// S3에 이미지 업로드
    private func putImageToS3(
        presignedUrl: String,
        imageData: Data,
        fileName: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        var request = URLRequest(url: URL(string: presignedUrl)!)
        request.httpMethod = "PUT"
        request.setValue("image/png", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(.success(()))
            } else {
                let error = NSError(
                    domain: "ImageUploadError",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to upload image"]
                )
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
