//
//  VoiceDiaryTipView.swift
//  GrowIT
//
//  Created by 이수현 on 1/18/25.
//

import UIKit

class VoiceDiaryTipView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Components
    private let grabberIcon = UIImageView().then {
        $0.image = UIImage(named: "grabberIcon")
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var diaryIcon = UIImageView().then {
        $0.image = UIImage(named: "bulbIcon")
        $0.backgroundColor = .clear
    }
    
    private lazy var title = UILabel().then {
        $0.text = "그로우잇 일기 작성 Tip"
        $0.font = .heading2Bold()
        $0.textColor = .white
    }
    
    let contentView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 0
    }).then {
        $0.backgroundColor = .clear
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.register(VoiceDiaryTipCell.self, forCellWithReuseIdentifier: VoiceDiaryTipCell.identifier)
    }
    
    let exitButton = AppButton(title: "확인했어요", titleColor: .black).then {
        $0.backgroundColor = .primary400
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .gray800
        addSubview(grabberIcon)
        grabberIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(80)
            $0.height.equalTo(4)
        }
        
        addSubview(diaryIcon)
        diaryIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalTo(grabberIcon.snp.bottom).offset(24)
            make.width.height.equalTo(28)
        }
        
        addSubview(title)
        title.snp.makeConstraints { make in
            make.leading.equalTo(diaryIcon.snp.leading)
            make.top.equalTo(diaryIcon.snp.bottom).offset(8)
        }
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(320)
        }
        
        addSubview(exitButton)
        exitButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
            make.top.equalTo(contentView.snp.bottom).offset(40)
            let bottomInset = max(self.safeAreaInsets.bottom, 20)
            make.bottom.equalToSuperview().offset(-bottomInset)
        }
    }

}
