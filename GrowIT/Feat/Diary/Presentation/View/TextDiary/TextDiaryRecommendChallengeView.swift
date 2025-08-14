//
//  TextDiaryRecommendChallengeView.swift
//  GrowIT
//
//  Created by 이수현 on 1/12/25.
//

import UIKit

class TextDiaryRecommendChallengeView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Components
    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .clear
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let recommendLabel = UILabel().then {
        $0.text = "현재 감정에 맞는\n챌린지를 추천할게요"
        $0.numberOfLines = 0
        $0.font = .subTitle1()
        $0.textColor = .black
    }
    
    private let emoLabel = UILabel().then {
        $0.text = "오늘의 감정 키워드"
        $0.font = .body1Medium()
        $0.textColor = .gray500
    }
    
    private let emoStackView = EmoStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .equalSpacing
        $0.backgroundColor = .clear
    }
    
    let challengeStackView = TextDiaryChallengeStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.distribution = .equalSpacing
        $0.backgroundColor = .clear
    }
    
    let saveButton = AppButton(title: "챌린지 저장하기").then {
        $0.setButtonState(isEnabled: false, enabledColor: .black, disabledColor: .gray100, enabledTitleColor: .white, disabledTitleColor: .gray400)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = "선택한 챌린지만 보관함으로 이동해요"
        $0.font = .body2Medium()
        $0.textColor = .gray400
    }
    
    private let toolTip = ToolTipView()
    
    //MARK: - Setup UI
    private func setupUI() {
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        contentView.addSubview(recommendLabel)
        recommendLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(32)
        }
        
        contentView.addSubview(emoLabel)
        emoLabel.snp.makeConstraints { make in
            make.leading.equalTo(recommendLabel.snp.leading)
            make.top.equalTo(recommendLabel.snp.bottom).offset(28)
        }
        
        contentView.addSubview(emoStackView)
        emoStackView.snp.makeConstraints { make in
            make.leading.equalTo(emoLabel.snp.leading)
            make.top.equalTo(emoLabel.snp.bottom).offset(8)
        }
        
        contentView.addSubview(toolTip)
        toolTip.snp.makeConstraints { make in
            make.top.equalTo(emoStackView.snp.bottom).offset(24)
            make.height.equalTo(47)
            make.centerX.equalToSuperview()
        }
        
        contentView.addSubview(challengeStackView)
        challengeStackView.snp.makeConstraints { make in
            make.leading.equalTo(emoStackView.snp.leading)
            make.top.equalTo(toolTip.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        contentView.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(challengeStackView.snp.bottom).offset(58)
            make.leading.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
        }
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(saveButton.snp.bottom).offset(8)
        }
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(descriptionLabel.snp.bottom).offset(40)
        }
    }
    
    func updateEmo(emotionKeywords: [EmotionKeyword]) {
        let keywords = emotionKeywords.prefix(3).map { $0.keyword }
        emoStackView.updateLabels(with: keywords)
    }
    
    func updateChallenges(_ challenges: [RecommendedChallenge]) {
        let titles = challenges.prefix(3).map { $0.title }
        let times = challenges.prefix(3).map { "\($0.time)분" }
        let content = challenges.prefix(3).map { $0.content }
        
        challengeStackView.updateChallengeTitles(titles: titles, times: times, contents: content)
    }
    
}
