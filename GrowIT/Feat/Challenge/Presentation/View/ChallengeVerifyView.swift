//
//  ChallengeVerifyView.swift
//  GrowIT
//
//  Created by 허준호 on 1/24/25.
//

import UIKit
import Then
import SnapKit

class ChallengeVerifyView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addComponents()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Property
    
    private lazy var challengeIcon = UIImageView().then{
        $0.image = UIImage(named: "challengeListIcon")
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var challengeName = makeLabel(title: "", color: .black, font: .heading1Bold())
    
    private lazy var subTitle = makeLabel(title: "챌린지를 인증하고 크레딧을 얻어 보세요!", color: .gray500, font: .body2Medium())
    
    private lazy var imageUploadLabel = makeLabel(title: "인증샷 업로드", color: .gray900, font: .heading3Bold())
    
    private lazy var imageUploadIcon = UIImageView().then{
        $0.image = UIImage(named: "imageUploadIcon")
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var imageUploadText = makeLabel(title: "인증샷 업로드하기 (0/1)", color: .gray500, font: .body1Medium())
    
    public lazy var imageContainer = UIImageView().then{
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var oneLineReviewLabel = makeLabel(title: "챌린지 한줄소감", color: .gray900, font: .heading3Bold())
    
    //private lazy var reviewContainer = makeContainer()
    
    public lazy var reviewTextView = UITextView().then{
        $0.backgroundColor = .white
        $0.isScrollEnabled = false
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        $0.textContainerInset = .init(top: 12, left: 12, bottom: 12, right: 12)
        $0.returnKeyType = .done
        $0.textColor = UIColor.gray300 // 플레이스홀더 색상처럼 보이게
    }
    
    private lazy var reviewHintText = makeLabel(title: "챌린지 한줄소감을 50자 이상 적어 주세요", color: .gray500, font: .detail2Regular())
    
    public lazy var challengeVerifyButton = AppButton(title: "챌린지 인증하기", titleColor: .gray400, isEnabled: false, icon: "").then{
        $0.setButtonState(isEnabled: false, enabledColor: .black, disabledColor: .gray100, enabledTitleColor: .white, disabledTitleColor: .gray400)
    }
    
    // MARK: - Stack
    private lazy var titleStack = makeStack(axis: .vertical, spacing: 4)
    
    public lazy var imageStack = makeStack(axis: .vertical, spacing: 8)
    
    public lazy var imageUploadStack = makeStack(axis: .horizontal, spacing: 10)
    
    private lazy var reviewStack = makeStack(axis: .vertical, spacing: 8)
    
    
    // MARK: - Func
    private func makeLabel(title:String, color: UIColor, font: UIFont) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textColor = color
        label.font = font
        label.adjustsFontSizeToFitWidth = true
        return label
    }
    
    private func makeStack(axis: NSLayoutConstraint.Axis, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        return stackView
    }
    
    private func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        view.layer.borderWidth = 1
        return view
    }
    
    public func imageUploadCompleted(_ image:UIImage){
        imageContainer.image = image
        imageContainer.contentMode = .scaleAspectFill
        imageContainer.clipsToBounds = true
        imageUploadStack.isHidden = true
        
        imageContainer.snp.remakeConstraints {
            $0.height.width.equalTo(140)
        }
        
        imageStack.snp.remakeConstraints{
            $0.top.equalTo(titleStack.snp.bottom).offset(20)
            $0.left.equalTo(24)
        }
    }
    
    public func validateTextView(errorMessage: String, textColor: UIColor, bgColor:UIColor, borderColor: UIColor, hintColor: UIColor){
        reviewHintText.text = errorMessage
        reviewHintText.textColor = hintColor
        oneLineReviewLabel.textColor = textColor
        reviewTextView.textColor = textColor
        reviewTextView.backgroundColor = bgColor
        reviewTextView.layer.borderColor = borderColor.cgColor
    }
    
    public func setChallengeName(name: String){
        challengeName.text = name
    }
    
    // MARK: - addFunc & Constraints
    private func addComponents(){
        [challengeIcon, titleStack, imageStack, reviewStack, reviewHintText, challengeVerifyButton].forEach(self.addSubview)
        [challengeName, subTitle].forEach(titleStack.addArrangedSubview)
        [imageUploadLabel, imageContainer].forEach(imageStack.addArrangedSubview)
        [oneLineReviewLabel, reviewTextView].forEach(reviewStack.addArrangedSubview)
        imageContainer.addSubview(imageUploadStack)
        [imageUploadIcon, imageUploadText].forEach(imageUploadStack.addArrangedSubview)
    }
    
    private func constraints(){
        challengeIcon.snp.makeConstraints{
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(32)
            $0.left.equalToSuperview().offset(24)
            $0.width.height.equalTo(40)
        }
        
        titleStack.snp.makeConstraints{
            $0.top.equalTo(challengeIcon.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(24)
        }
        
        imageContainer.snp.makeConstraints{
            $0.height.equalTo(72)
        }
        
        imageUploadIcon.snp.makeConstraints{
            $0.width.height.equalTo(34)
        }
        
        imageUploadStack.snp.makeConstraints{
            $0.center.equalToSuperview()
        }
        
        imageStack.snp.makeConstraints{
            $0.top.equalTo(titleStack.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        reviewTextView.snp.makeConstraints{
            $0.height.equalTo(140)
        }
        reviewStack.snp.makeConstraints {
            $0.top.equalTo(imageStack.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        reviewHintText.snp.makeConstraints{
            $0.top.equalTo(reviewStack.snp.bottom).offset(4)
            $0.left.equalToSuperview().offset(24)
        }
        
        challengeVerifyButton.snp.makeConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(20)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
    }
    
}
