//
//  S3Response.swift
//  GrowIT
//
//  Created by 허준호 on 2/12/25.
//

import Foundation

struct S3UploadUrlResponseDTO: Decodable {
    let presignedUrl: String
    let fileUrl: String
}

struct S3DownloadUrlResponseDTO: Decodable{
    let result: String
}

