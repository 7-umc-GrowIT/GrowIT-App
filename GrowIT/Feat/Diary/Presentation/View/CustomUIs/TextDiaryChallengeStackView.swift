//
//  ChallengeStackView.swift
//  GrowIT
//
//  Created by 이수현 on 1/12/25.
//

import UIKit
import SnapKit

class TextDiaryChallengeStackView: UIStackView {
    
    // ChallengeItemView 배열 추가
    var challengeViews: [ChallengeItemView] = [
        ChallengeItemView(),
        ChallengeItemView(),
        ChallengeItemView()
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        axis = .vertical
        spacing = 10
        
        // StackView에 challengeViews 추가
        challengeViews.forEach { addArrangedSubview($0) }
    }

    func updateChallengeTitles(titles: [String], times: [String], contents: [String]) {
        for (index, challengeView) in challengeViews.enumerated() {
            if index < titles.count {
                challengeView.updateTitle(title: titles[index], time: times[index], content: contents[index])
            }
        }
    }
}
