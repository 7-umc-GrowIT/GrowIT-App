//
//  ChallengeCompleteView.swift
//  GrowIT
//
//  Created by 허준호 on 1/27/25.
//

import UIKit
import Then
import SnapKit
import SwiftUI

struct ChallengeCompleteScreen: View {
    let challenge: ChallengeDTO = ChallengeDTO(id: 0, title: "좋아하는 책 독서하기 좋아하는 책 독서하기 좋아하는 책 독서하기 좋아하는 책 독서하기", certificationImageUrl: "https://cdnweb01.wikitree.co.kr/webdata/editor/202408/16/img_20240816175532_b82de03f.webp", thoughts: "오늘의 챌린지에 대한 한줄 소감입니다", time: 1, certificationDate: "2025년 8월 12일 인증")
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack(alignment: .leading){
                Image("grabberIcon")
                    .resizable()
                    .frame(width: 80, height: 4)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                Image("challengeCompleteIcon")
                    .resizable()
                    .frame(width: 28, height: 28)
                DefaultLabel(title: "챌린지 인증 완료!", color: .primary600, font: .heading2Bold)
                Spacer().frame(height: 16)
                DefaultLabel(title: "어떤 챌린지인가요?", color: .gray900, font: .heading3Bold)
                Spacer().frame(height: 8)
                ChallengeCompleteCard(challenge: challenge)
                Spacer().frame(height: 8)
                DefaultLabel(title: challenge.certificationDate, color: .gray500, font: .body2Medium)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Spacer().frame(height: 24)
                DefaultLabel(title: "챌린지 인증샷", color: .gray900, font: .heading3Bold)
                Spacer().frame(height: 8)
                CertificationImageBox(url: challenge.certificationImageUrl)
                Spacer().frame(height: 24)
                DefaultLabel(title: "챌린지 한줄소감", color: .gray900, font: .heading3Bold)
                Spacer().frame(height: 8)
                ReviewBox(review: challenge.thoughts)
                Spacer().frame(height: 4)
                DefaultLabel(title: "챌린지 한줄소감을 50자 이상 적어 주세요", color: .gray500, font: .detail2Regular)
                Spacer().frame(height: 40)
                HStack(spacing: 8){
                    ChallengeCompleteButton(title: "나가기", onTap: {})
                    ChallengeCompleteButton(title: "수정하기", onTap: {})
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, 24)
        }
        }
}

// MARK: - 챌린지 완료 카드
struct ChallengeCompleteCard: View {
    let challenge: ChallengeDTO
    
    var body: some View {
        HStack{
            // 아이콘
            Image("challengeIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            
            Spacer().frame(width: 12)
            
            // 중앙 컨텐츠 (제목 + 시간)
            VStack(alignment: .leading, spacing: 8) {
                // 제목
                Text(challenge.title)
                    .foregroundColor(.gray900)
                    .styled(.heading3Bold)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 시간 정보
                HStack(spacing: 4) {
                    Image("timeIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                    
                    Text(challenge.time.formattedTime)
                        .foregroundColor(.primary600)
                        .styled(.body2Medium)
                }
            }
            .frame(maxWidth: .infinity)
            
            Text("인증하기")
                .styled(.detail1Medium)
                .foregroundColor(.gray400)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.gray100)
                .clipShape(RoundedRectangle(cornerRadius: 999))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24.5)
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - 인증 이미지 박스
struct CertificationImageBox: View {
    let url: String
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } placeholder: {
            RoundedRectangle(cornerRadius: 8)
                .fill(.gray200)
                .frame(width: 140, height: 140)
                .overlay(
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                )
        }
    }
}

// MARK: - 인증 리뷰 박스
struct ReviewBox: View {
    let review: String
    
    var body: some View {
        DefaultLabel(title: review, color: .gray900, font: .body1Medium)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .padding(.all, 12)
            .frame(maxWidth: .infinity, alignment: .leading) // 🎯 먼저 가로 정렬
            .frame(height: 140, alignment: .top) // 🎯 그 다음 세로 정렬
            .overlay{
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.black.opacity(0.1), lineWidth: 1)
            }
            
    }
}

// MARK: - 공통 버튼
struct ChallengeCompleteButton: View {
    let title: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap){
            DefaultLabel(title: title, color: .gray400, font: .heading2Bold)
                .padding(.vertical, 17)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60, alignment: .center)
        .background(.gray100)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        
    }
}
struct ChallengeCompletePreview: PreviewProvider {
    static var previews: some View {
        ChallengeCompleteScreen()
    }
}



class ChallengeCompleteView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addStack()
        addComponents()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Property
    
    private lazy var grabberIcon = makeIcon(name: "grabberIcon")
    
    private lazy var scrollView = UIScrollView(frame: self.bounds).then{
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.contentOffset = CGPoint(x: 0, y: 0)
        $0.contentSize = contentView.bounds.size
    }
    
    private lazy var contentView = UIView().then{
        $0.backgroundColor = .clear
    }
    private lazy var titleIcon = makeIcon(name: "challengeCompleteIcon")
    
    private lazy var title = makeLabel(title: "챌린지 인증완료!", color: .primary600, font: .heading1Bold()).then{
        $0.textAlignment = .left
    }
    
    private lazy var challengeLabel = makeLabel(title: "어떤 챌린지인가요?", color: .gray900, font: .heading3Bold())
    
    private lazy var challengeContainer = makeContainer(radius: 20)
    
    private lazy var challengeIcon = makeIcon(name: "challengeListIcon")
    
    private lazy var challengeName = makeLabel(title: "", color: .gray900, font: .heading3Bold())
    
    private lazy var clockIcon = makeIcon(name: "timeIcon")
    
    private lazy var challengeTime = makeLabel(title: "", color: .primary600, font: .body2Medium())
    
    private lazy var challengeVerifyDate = makeLabel(title: "", color: .gray500, font: .body2Medium()).then{
        $0.textAlignment = .right
    }
    
    private lazy var imageLabel = makeLabel(title: "챌린지 인증샷", color: .gray900, font: .heading3Bold())
    
    public lazy var imageContainer = UIImageView().then{
        $0.image = UIImage()
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var reviewLabel = makeLabel(title: "챌린지 한줄소감", color: .gray900, font: .heading3Bold())
    
    public lazy var reviewContainer = UITextView().then{
        $0.text = ""
        $0.textColor = .gray900
        $0.font = .body1Medium()
        $0.backgroundColor = .white
        $0.isScrollEnabled = false
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        $0.textContainerInset = .init(top: 12, left: 12, bottom: 12, right: 12)
        $0.returnKeyType = .done
        $0.setLineSpacing(spacing: 8, font: .body1Medium(), color: .gray900)
    }
    
    private lazy var reviewHintText = makeLabel(title: "챌린지 한줄소감을 50자 이상 적어 주세요", color: .gray500, font: .detail2Regular())
    
    public lazy var challengeExitButton = makeButton(title: "나가기", textColor: .gray400, bgColor: .gray100)
    
    public lazy var challengeUpdateButton = AppButton(title: "수정하기", titleColor: .gray400, isEnabled: false,  icon: "").then{
        $0.backgroundColor = .gray100
    }
    
    
    // MARK: - Stack
    private lazy var titleStack = makeStack(axis: .vertical, spacing: 8)
    
    private lazy var challengeStack = makeStack(axis: .vertical, spacing: 8)
    
    public lazy var imageStack = makeStack(axis: .vertical, spacing: 8)
    
    private lazy var reviewStack = makeStack(axis: .vertical, spacing: 8)
    
    private lazy var buttonStack = makeStack(axis: .horizontal, spacing: 8).then{
        $0.distribution = .fillEqually
    }
    
    private lazy var challengeCompleteStack = makeStack(axis: .vertical, spacing: 0)
    
    // MARK: - Func
    
    private func makeIcon(name: String) -> UIImageView {
        let icon = UIImageView()
        icon.image = UIImage(named: name)
        icon.contentMode = .scaleAspectFit
        return icon
    }
    
    private func makeLabel(title:String, color: UIColor, font: UIFont) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textColor = color
        label.font = font
        return label
    }
    
    private func makeStack(axis: NSLayoutConstraint.Axis, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        return stackView
    }
    
    private func makeContainer(radius: Double) -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = radius
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        view.layer.borderWidth = 1
        return view
    }
    
    private func makeButton(title:String, textColor: UIColor, bgColor: UIColor) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.titleLabel?.font = .heading2Bold()
        button.backgroundColor = bgColor
        button.layer.cornerRadius = 16
        return button
    }
    
    public func setupChallenge(challenge: ChallengeDTO){
        challengeName.text = challenge.title
        challengeTime.text = challenge.time.formattedTime
        reviewContainer.text = challenge.thoughts
        reviewContainer.setLineSpacing(spacing: 4, font: .body1Medium(), color: .gray900)
        var dateList : [String] = []
        let fullDate = challenge.certificationDate.split(separator: "T")[0]
        fullDate.split(separator: "-").forEach { (element) in
            dateList.append(String(element))
        }
        
        challengeVerifyDate.text = dateList[0] + "년 " + dateList[1] + "월 " + dateList[2] + "일 인증"
    }
    
    public func updateImage(image: UIImage){
        imageContainer.image = image
        imageContainer.contentMode = .scaleAspectFill
    }
    
    public func setUpdateBtnActivate(_ activate: Bool){
        challengeUpdateButton.setButtonState(isEnabled: activate, enabledColor: .black, disabledColor: .gray100, enabledTitleColor: .white, disabledTitleColor: .gray400)
        self.layoutIfNeeded()
    }
    
    public func validateTextView(errorMessage: String, textColor: UIColor, bgColor:UIColor, borderColor: UIColor, hintColor: UIColor){
        reviewHintText.text = errorMessage
        reviewHintText.textColor = hintColor
        reviewLabel.textColor = textColor
        reviewContainer.textColor = textColor
        reviewContainer.backgroundColor = bgColor
        reviewContainer.layer.borderColor = borderColor.cgColor
    }
    
    // MARK: - addFunc & Constraints
    
    private func addStack(){
        [challengeLabel, challengeContainer, challengeVerifyDate].forEach(challengeStack.addArrangedSubview)
        [imageLabel, imageContainer].forEach(imageStack.addArrangedSubview)
        [reviewLabel, reviewContainer].forEach(reviewStack.addArrangedSubview)
        [challengeExitButton, challengeUpdateButton].forEach(buttonStack.addArrangedSubview)
        [titleIcon, title, challengeStack, imageStack, reviewStack, reviewHintText, buttonStack].forEach(challengeCompleteStack.addArrangedSubview)
    }
    
    private func addComponents(){
        self.addSubview(scrollView)
        [grabberIcon, titleIcon, title, challengeStack, imageStack, reviewStack, reviewHintText, buttonStack].forEach(contentView.addSubview)
        scrollView.addSubview(contentView)
        [challengeIcon, challengeName, clockIcon, challengeTime].forEach(challengeContainer.addSubview)
    }
    
    private func constraints(){
        
        
        
        scrollView.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints{
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
            
        }
        
        grabberIcon.snp.makeConstraints{
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(4)
            $0.width.equalTo(80)
        }
        
        titleIcon.snp.makeConstraints{
            $0.top.equalTo(grabberIcon.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(24)
            $0.width.height.equalTo(28)
        }
        
        
        title.snp.makeConstraints{
            $0.top.equalTo(titleIcon.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(24)
        }
        
        challengeIcon.snp.makeConstraints{
            $0.verticalEdges.equalToSuperview().inset(30)
            $0.left.equalToSuperview().offset(24)
            $0.width.height.equalTo(40)
        }
        
        challengeName.snp.makeConstraints{
            $0.top.equalToSuperview().offset(24.5)
            $0.left.equalTo(challengeIcon.snp.right).offset(12)
        }
        
        clockIcon.snp.makeConstraints{
            $0.bottom.equalToSuperview().inset(24.5)
            $0.left.equalTo(challengeIcon.snp.right).offset(12)
            $0.width.height.equalTo(16)
        }
        
        challengeTime.snp.makeConstraints{
            $0.top.equalTo(clockIcon.snp.top)
            $0.left.equalTo(clockIcon.snp.right).offset(4)
        }
        
        challengeStack.snp.makeConstraints{
            $0.top.equalTo(title.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        imageContainer.snp.makeConstraints{
            $0.width.height.equalTo(140)
        }
        
        imageStack.snp.makeConstraints{
            $0.top.equalTo(challengeStack.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(24)
        }
        
        reviewContainer.snp.makeConstraints{
            $0.height.equalTo(140)
        }
        
        reviewStack.snp.makeConstraints{
            $0.top.equalTo(imageStack.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        reviewHintText.snp.makeConstraints {
            $0.left.equalToSuperview().offset(24)
            $0.top.equalTo(reviewStack.snp.bottom).offset(4)
        }
        
        buttonStack.snp.makeConstraints{
            $0.top.equalTo(reviewHintText.snp.bottom).offset(40)
            //$0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(20)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(60)
        }
    }
}
