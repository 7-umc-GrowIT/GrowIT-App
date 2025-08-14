//
//  JDiaryHomeBannerView.swift
//  GrowIT
//
//  Created by 허준호 on 1/15/25.
//

import UIKit
import Then
import SnapKit
import Lottie

class JDiaryHomeBanner: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addStack()
        addComponents()
        constraints()
        
        postImage.play()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Property
    
    private lazy var bannerBg = UIImageView().then{
        $0.image = UIImage(named: "jDiaryHomeBanner")
        $0.contentMode = .scaleToFill
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var title = makeLabel(title: "오늘의 일기 작성하기", font: .subHeading1(), color: .gray900)
    
    private lazy var subTitle = makeLabel(title: "간편하게 대화하고 내 감정을 기록해요", font: .body2Medium(), color: .primary600)
    
    private lazy var postImage = LottieAnimationView(name: "Diary").then {
        $0.frame = CGRect(x: 0, y: 0, width: 162, height: 153)
        //$0.sizeToFit()
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
//        $0.layer.borderColor = UIColor.red.cgColor
//        $0.layer.borderWidth = 1
        $0.loopMode = .loop
    }
    
    private lazy var diaryWriteIcon = UIImageView().then{
        $0.image = UIImage(named: "diaryIcon")
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var diaryWriteLabel = makeLabel(title: "오늘의 일기 기록하기", font: .heading2Bold(), color: .white)
    
    lazy var diaryWriteButton = UIView().then{
        $0.backgroundColor = .black
        $0.layer.cornerRadius =  16
        $0.isUserInteractionEnabled = true
    }
    
    public lazy var diaryDirectWriteButton = UILabel().then {
        $0.text = "오늘은 직접 작성할게요"
        $0.font = .body2Medium()
        $0.textColor = .primary600
        $0.isUserInteractionEnabled = true
    }
    
    // MARK: - Stack
    private lazy var titleStack = makeStack(spacing: 4, axis: .vertical)
    
    private lazy var diaryWriteStack = makeStack(spacing: 10, axis: .horizontal)
    
    // MARK: - Function
    private func makeStack(spacing: CGFloat, axis: NSLayoutConstraint.Axis) -> UIStackView{
        let stack = UIStackView()
        stack.axis = axis
        stack.spacing = spacing
        stack.distribution = .equalSpacing
        return stack
    }
    
    private func makeLabel(title: String, font: UIFont, color: UIColor) -> UILabel{
        let label = UILabel()
        label.text = title
        label.font = font
        label.textColor = color
        return label
    }
    
    // MARK: - addFunction & Constraints
    
    private func addStack(){
        [title, subTitle].forEach(titleStack.addArrangedSubview)
        [diaryWriteIcon, diaryWriteLabel].forEach(diaryWriteStack.addArrangedSubview)
    }
    
    private func addComponents(){
        addSubview(bannerBg)
        [titleStack, postImage, diaryWriteButton, diaryDirectWriteButton].forEach(bannerBg.addSubview)
        diaryWriteButton.addSubview(diaryWriteStack)
    }
    
    private func constraints(){
        
        bannerBg.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        
        titleStack.snp.makeConstraints{
            $0.top.equalToSuperview().offset(32)
            $0.left.equalToSuperview().offset(24)
        }
        
        postImage.snp.makeConstraints{
//            $0.centerX.equalToSuperview()
//            $0.centerY.equalToSuperview()
            $0.horizontalEdges.top.equalToSuperview()
            $0.bottom.equalToSuperview().inset(20)
        }
        
        diaryWriteStack.snp.makeConstraints{
            $0.verticalEdges.equalToSuperview().inset(17)
            $0.centerX.equalToSuperview()
        }
        
        diaryWriteButton.snp.makeConstraints{
            //$0.top.equalTo(postImage.snp.bottom).offset(23)
            $0.bottom.equalToSuperview().inset(68)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        diaryDirectWriteButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(31.5)
        }
    }
    
}
