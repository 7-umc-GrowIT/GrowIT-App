//
//  Diary.swift
//  GrowIT
//
//  Created by 허준호 on 8/29/25.
//

struct Diary {
    let id: Int
    let content: String
    let date: String
}

extension Diary {
    init(dto: DiaryResponseDTO) {
        self.id = dto.diaryId
        self.content = dto.content
        self.date = dto.date
    }
}
