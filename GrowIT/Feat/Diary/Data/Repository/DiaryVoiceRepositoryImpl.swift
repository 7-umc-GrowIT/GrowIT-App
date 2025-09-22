//
//  DiaryRepositoryImpl.swift
//  GrowIT
//
//  Created by 허준호 on 8/16/25.
//

class DiaryVoiceRepositoryImpl: DiaryVoiceRepository {
    private let dataSource: DiaryVoiceDataSource
    
    init(dataSource: DiaryVoiceDataSource) {
        self.dataSource = dataSource
    }
    
    func postVoiceDiary(data: DiaryVoiceRequestDTO) async throws -> String {
        let response = try await dataSource.postVoiceDiary(data: data)
        return response.chat
    }
    
    func postVoiceDiaryDate(date: String) async throws -> Diary {
        let response = try await dataSource.postVoiceDiaryDate(date: date)
        return Diary(dto: response)
    }
}
