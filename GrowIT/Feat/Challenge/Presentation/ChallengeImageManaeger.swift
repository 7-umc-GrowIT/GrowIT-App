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
            data: PresignedUrlRequestDTO(contentType: "image/png")
        ) { result in
            switch result {
            case .success(let data):
                print("✅ Presigned URL 수신:", data.presignedUrl)
                print("✅ FileName 수신:", data.fileName)
                self.putImageToS3(
                    presignedUrl: data.presignedUrl,
                    imageData: imageData,
                    fileName: data.fileName
                ) { uploadResult in
                    switch uploadResult {
                    case .success:
                        completion(.success(data.fileName))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                print("Presigned URL 요청 에러: \(error)")
                completion(.failure(error)
                )
            }
        }
    }
    
    /// S3에 이미지 업로드
    private func putImageToS3(
            presignedUrl: String,
            imageData: Data,
            fileName: String,
            completion: @escaping (Result<Void, Error>) -> Void
        ) {
            guard let url = URL(string: presignedUrl) else {
                completion(.failure(NSError(
                    domain: "ImageUploadError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid presigned URL"]
                )))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("image/png", forHTTPHeaderField: "Content-Type")
            request.httpBody = imageData
            
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    print("Error during the upload: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("Image uploaded successfully!")
                    completion(.success(()))
                } else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    let error = NSError(
                        domain: "ImageUploadError",
                        code: statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "Upload failed with status: \(statusCode)"]
                    )
                    print("Error during the upload: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
}
