//
//  S3Service.swift
//  GrowIT
//
//  Created by 허준호 on 2/12/25.
//

import Foundation
import Moya

final class S3Service: NetworkManager {
    typealias Endpoint = S3Endpoint
    
    let provider: MoyaProvider<S3Endpoint>
    
    init(provider: MoyaProvider<S3Endpoint>? = nil) {
        let plugins: [PluginType] = [
            //NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
            AuthPlugin()
        ]
        
        self.provider = provider ?? MoyaProvider<S3Endpoint>(plugins: plugins)
    }
    
    /// Put s3 Upload Url API
    func putS3UploadUrl(fileName: String, completion: @escaping (Result<S3UploadUrlResponseDTO, NetworkError>) -> Void) {
        request(target: .putUploadUrl(folder: "challenges", fileName: fileName), decodingType: S3UploadUrlResponseDTO.self, completion: completion)
    }
    
    /// Get S3 Download Url API
    func getS3DownloadUrl(fileName: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .getDownloadUrl(folder: "challenges", fileName: fileName), decodingType: String.self, completion: completion)
    }
}
