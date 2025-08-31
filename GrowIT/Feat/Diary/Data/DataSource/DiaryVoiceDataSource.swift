//
//  DiaryVoiceDataSource.swift
//  GrowIT
//
//  Created by 허준호 on 8/16/25.
//

protocol DiaryVoiceDataSource {
    func postVoiceDiary(data: DiaryVoiceDTO) async throws -> DiaryVoiceDTO
    
    func postVoiceDiaryDate(date: String) async throws -> DiaryTextPostResponseDTO
}

class DiaryVoiceDataSourceImpl: DiaryVoiceDataSource {
    private let diaryService: DiaryService
    
    init(diaryService: DiaryService) {
        self.diaryService = diaryService
    }
    
    func postVoiceDiary(data: DiaryVoiceDTO) async throws -> DiaryVoiceDTO {
        return try await withCheckedThrowingContinuation { continuation in
           diaryService.postVoiceDiary(data: data) { result in
               switch result {
               case .success(let data):
                   continuation.resume(returning: data)
               case .failure(let error):
                   print("서버에 음성대화 보내기 실패")
                   continuation.resume(throwing: error)
               }
           }
       }
    }
    
    func postVoiceDiaryDate(date: String) async throws -> DiaryTextPostResponseDTO {
        return try await withCheckedThrowingContinuation{
            continuation in
            diaryService.postVoiceDiaryDate(data: DiaryVoiceDateRequestDTO(date: date)) { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    
}
