//
//  OnboardingView.swift
//  GrowIT
//
//  Created by 허준호 on 2/6/25.
//

import UIKit
import Then
import SnapKit

class OnboardingView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addComponents()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Property
    public lazy var imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then{
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
        $0.scrollDirection = .horizontal
        $0.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }).then{
        $0.register(OnboardingImageCell.self, forCellWithReuseIdentifier: OnboardingImageCell.identifier)
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
    }
    
    public lazy var title = UILabel().then{
        $0.text = "챌린지를 완료하고\n내 캐릭터를 꾸며보세요!"
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.textColor = .gray900
        $0.font = .heading1Bold()
    }
    
    public lazy var startBtn = UIButton().then {
        $0.setTitle("그로우잇 시작하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .heading2Bold()
        $0.setImage(UIImage(named: "GrowIT_Credit"), for: .normal)
        $0.backgroundColor = .black // 배경색 설정 예시
        $0.layer.cornerRadius = 16       // 모서리 둥글게 설정 예시
        
        // 이미지와 타이틀 사이의 간격 설정
        let spacing: CGFloat = 8
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0,left: spacing, bottom: 0,right: 0)
        
        // 버튼의 높이와 패딩 설정
        $0.contentEdgeInsets = UIEdgeInsets(top: 10,left: 16,bottom: 10,right: 16)
    }
    
    
    public lazy var loginBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("이미 계정이 있다면?     로그인하기", for: .normal)
        button.setTitleColor(.gray400, for: .normal)
        button.titleLabel?.font = UIFont.body2Medium()
        
        let fullText = "이미 계정이 있다면?     로그인하기"
        let attributedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: "로그인하기")
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.primary600, range: range)
        attributedString.addAttribute(.font, value: UIFont.body2Medium(), range: range)
        
        button.setAttributedTitle(attributedString, for: .normal)
        
        return button
    }()
    
    // MARK: - addFunc & Constraints
    
    private func addComponents() {
        [imageCollectionView, title, startBtn, loginBtn].forEach(self.addSubview)
    }
    
    private func constraints(){
        imageCollectionView.snp.makeConstraints{
            $0.top.equalToSuperview().offset(-UIApplication.shared.statusBarFrame.height)
//            $0.top.equalTo(self.safeAreaInsets.top).offset(-UIApplication.shared.statusBarFrame.height)  // 상태바 높이만큼 오프셋을 줘서 위로 올림
            $0.horizontalEdges.equalToSuperview()
            //$0.height.equalToSuperview().multipliedBy(0.536)
            $0.height.equalToSuperview().multipliedBy(0.6)
        }
        
        title.snp.makeConstraints{
            $0.top.equalTo(imageCollectionView.snp.bottom).offset(64)
            $0.centerX.equalToSuperview()
        }
        
        startBtn.snp.makeConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(68)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }
        
        loginBtn.snp.makeConstraints{
            $0.top.equalTo(startBtn.snp.bottom).offset(19.5)
            $0.centerX.equalToSuperview()
        }
    }
    
}
