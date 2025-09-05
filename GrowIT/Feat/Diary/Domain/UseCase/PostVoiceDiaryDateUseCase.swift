//
//  PostVoiceDiaryDate.swift
//  GrowIT
//
//  Created by 허준호 on 8/29/25.
//

class PostVoiceDiaryDateUseCase {
    private let repository: DiaryVoiceRepository
    
    init(repository: DiaryVoiceRepository) {
        self.repository = repository
    }
    
    func execute(date: String) async throws -> Diary {
        return try await repository.postVoiceDiaryDate(date: date)
    }
}
