//
//  DiaryService.swift
//  GrowIT
//
//  Created by 이수현 on 1/18/25.
//

import Foundation
import Moya

final class DiaryService: NetworkManager {
    typealias Endpoint = DiaryEndpoint
    
    let provider: MoyaProvider<DiaryEndpoint>
    
    init(provider: MoyaProvider<DiaryEndpoint>? = nil) {
        let plugins: [PluginType] = [
            // NetworkLoggerPlugin(configuration: .init(logOptions: [.requestMethod, .successResponseBody])),
            AuthPlugin.shared
        ]
        
        self.provider = provider ?? MoyaProvider<DiaryEndpoint>(plugins: plugins)
    }
    
    /// Post Text Diary API
    func postTextDiary(data: DiaryRequestDTO, completion: @escaping (Result<DiaryResponseDTO, NetworkError>) -> Void) {
        request(target: .postTextDiary(data: data), decodingType: DiaryResponseDTO.self, completion: completion
        )
    }
    
    /// Post Voice Diary API
    func postVoiceDiary(data: DiaryVoiceRequestDTO, completion: @escaping (Result<DiaryVoiceDTO, NetworkError>) -> Void) {
        request(target: .postVoiceDiary(data: data), decodingType: DiaryVoiceDTO.self, completion: completion)
    }
    
    /// 음성일기 작성 후 요약 응답 DTO
    func postVoiceDiaryDate(data: DiaryVoiceDateRequestDTO, completion: @escaping (Result<DiaryResponseDTO, NetworkError>) -> Void) {
        request(target: .postDiaryDate(data: data), decodingType: DiaryResponseDTO.self, completion: completion)
    }
    
    /// Diary Id를 받아 Diary를 삭제하는 API
    func deleteDiary(diaryId: Int, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        requestStatusCode(target: .deleteDiary(diaryId: diaryId), completion: completion)
    }
    
    /// Diary Id를 받아 특정 일기를 조회하는 API
    func fetchDiary(diaryId: Int, completion: @escaping (Result<DiaryTextPostResponseDTO, NetworkError>) -> Void) {
        request(target: .getDiaryID(diaryId: diaryId), decodingType: DiaryTextPostResponseDTO.self, completion: completion)
    }
    
    /// 월별 일기 수 조회 API
    func fetchAllDiaries(year: Int, month: Int, completion: @escaping (Result<DiaryGetAllResponseDTO?, NetworkError>) -> Void) {
        requestOptional(
            target: .getAllDiary(year: year, month: month),
            decodingType: DiaryGetAllResponseDTO.self,
            completion: completion
        )
    }
    
    /// 월별 일기 작성 날짜 및 일기 Id 조회 API
    func fetchDiaryDates(year: Int, month: Int, completion: @escaping (Result<DiaryGetDatesResponseDTO?, NetworkError>) -> Void) {
        requestOptional(
            target: .getDiaryDates(year: year, month: month),
            decodingType: DiaryGetDatesResponseDTO.self,
            completion: completion
        )
    }
    
    func patchFixDiary(diaryId: Int, data: DiaryPatchDTO, completion: @escaping (Result<DiaryPatchResponseDTO, NetworkError>) -> Void) {
        request(target: .patchFixDiary(diaryId: diaryId, data: data), decodingType: DiaryPatchResponseDTO.self, completion: completion)
    }
    
    func postVoiceDiaryAnalyze(diaryId: Int, completion: @escaping (Result<DiaryAnalyzeResponseDTO, NetworkError>) -> Void) {
        request(target: .postDiaryAnalyze(diaryId: diaryId), decodingType: DiaryAnalyzeResponseDTO.self, completion: completion)
    }
    
    func fetchHasVoiceDiary(completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        request(target: .getHasVoiceDiary, decodingType: Bool.self, completion: completion)
    }
}

