//
//  ChallengeImageManaeger.swift
//  GrowIT
//
//  Created by 허준호 on 2/14/25.
//

import Foundation

class ChallengeImageManager {
    let s3Service = S3Service()
    var imageData: Data?
    
    init(imageData: Data? = nil) {
        self.imageData = imageData
    }
    
    /// 이미지 업로드 및 URL 반환
    func uploadImage(completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = imageData else {
            completion(.failure(NSError(domain: "ImageManagerError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Image data is nil"])))
            return
        }
        
        let fileName = UUID().uuidString + ".png"
        s3Service.putS3UploadUrl(fileName: fileName, completion: { result in
            switch result {
            case .success(let data):
                self.putImageToS3(presignedUrl: data.presignedUrl, imageData: imageData, fileName: fileName, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    /// S3에 이미지 업로드
    private func putImageToS3(presignedUrl: String, imageData: Data, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
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
                self.getS3ImageUrl(fileName: fileName, completion: completion)
            } else {
                let error = NSError(domain: "ImageUploadError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload image"])
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    /// S3 업로드 이미지 URL 받기
    private func getS3ImageUrl(fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        s3Service.getS3DownloadUrl(fileName: fileName, completion: { result in
            switch result {
            case .success(let data):
                if let url = data.components(separatedBy: "?").first {
                    completion(.success(url))
                } else {
                    let error = NSError(domain: "URLProcessingError", code: 2, userInfo: [NSLocalizedDescriptionKey: "URL processing failed"])
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}
