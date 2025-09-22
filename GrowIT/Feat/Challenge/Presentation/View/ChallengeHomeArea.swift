//
//  ChallengHomeNavbar.swift
//  GrowIT
//
//  Created by 허준호 on 1/20/25.
//

import UIKit
import Then
import SnapKit


class ChallengeHomeArea: UIView {
    
    private lazy var keywords : [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addStacdk()
        addComponents()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Property
    
    var currentPage: Int = 0
    var totalPages: Int = 0
    
    private lazy var bg = UIView().then{
        $0.backgroundColor = .red
    }
    
    private lazy var title = makeLabel(title: "오늘의 챌린지 추천", color: .black, font: .heading1Bold())
    
    private lazy var subTitle = makeLabel(title: "나의 심리 정보를 기반으로 챌린지를 추천해요", color: .gray500, font: .body2Medium())
    
    private lazy var todayChallengeBox = makeContainer()
    
    public lazy var todayChallengeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then{
        $0.minimumInteritemSpacing = 0
        $0.minimumLineSpacing = 0
        $0.scrollDirection = .horizontal
    }).then{
        $0.register(TodayChallengeCollectionViewCell.self, forCellWithReuseIdentifier: TodayChallengeCollectionViewCell.identifier)
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.isPagingEnabled = true
    }
    
    public lazy var pageControl = UIPageControl()
    
    private lazy var emptyChallengeIcon = UIImageView().then{
        $0.image = UIImage(named: "diary")
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    private lazy var emptyChallengeLabel = makeLabel(title: "오늘의 일기를 작성하고 챌린지를 진행해 보세요!", color: .gray400, font: .detail1Medium()).then{
        $0.isHidden = true
    }
    
    private lazy var challengeReportTitle = makeLabel(title: "그로의 챌린지 리포트", color: .black, font: .heading1Bold())
    
    private lazy var challengeReportSubTitle = makeLabel(title: "그로우잇과 얼마나 성장했는지 확인해 보세요!", color: .gray500, font: .body2Medium())
    
    private lazy var creditNumberContainer = makeContainer()
    
    private lazy var creditNumLabel = makeLabel(title: "총 크레딧 수", color: .gray500, font: .body2Medium()).then{
        $0.textAlignment = .center
    }
    
    private lazy var creditNumIcon = UIImageView().then{
        $0.image = UIImage(named: "creditNumIcon")
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var creditNum = makeLabel(title: "", color: .gray900, font: .heading2Bold())
    
    private lazy var writtenDiaryLabel = makeLabel(title: "작성된 일기 수", color: .gray500, font: .body2Medium()).then{
        $0.textAlignment = .center
    }
    
    private lazy var writtenDiaryIcon = UIImageView().then{
        $0.image = UIImage(named: "challengeListIcon")
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var writtenDiaryNumContainer = makeContainer()
    
    private lazy var writtenDiaryNum = makeLabel(title: "", color: .gray900, font: .heading2Bold())
    
    private lazy var diaryDatesLabel = makeLabel(title: "", color: .gray400, font: .body2Medium())
    
    // MARK: - Stack
    public lazy var titleStack = makeStack(axis: .vertical, spacing: 4)
    
    public lazy var hashTagStack = makeStack(axis: .horizontal, spacing: 8)
    
    
    public lazy var challengeReportTitleStack = makeStack(axis: .vertical, spacing: 4).then {
        $0.layer.borderColor = UIColor.green.cgColor
        $0.layer.borderWidth = 1
    }
    
    private lazy var creditNumStack1 = makeStack(axis: .horizontal, spacing: 4)
    
    private lazy var creditNumStack2 = makeStack(axis: .vertical, spacing: 8)
    
    private lazy var writtenDiaryStack1 = makeStack(axis: .horizontal, spacing: 4)
    
    private lazy var writtenDiaryStack2 = makeStack(axis: .vertical, spacing: 8)
    
    private lazy var emptyChallengeStack = makeStack(axis: .vertical, spacing: 16)
    
    private lazy var challengeReportContainerStack = makeStack(axis: .horizontal, spacing: 8).then{
        $0.distribution = .fillEqually
    }
    
    private lazy var challengePageContainer = makeStack(axis: .vertical, spacing: 0)
    
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
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.border.cgColor
        return view
    }
    
    private func makeChallengeHashTagLabel(title: String) -> UILabel {
        let label = PaddingLabel()
        label.text = title
        label.textColor = UIColor.primary700
        label.font = UIFont.body2SemiBold()
        label.backgroundColor = UIColor.primary100
        label.layer.cornerRadius = 6
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.border.cgColor
        label.layer.masksToBounds = true
        label.isUserInteractionEnabled = false
        return label
    }
    
    public func setupChallengeKeywords(_ values: [String]){
        keywords = values
        
        hashTagStack.arrangedSubviews.forEach { $0.removeFromSuperview() }  // 기존 버튼 제거
        keywords.forEach { keyword in
            let button = makeChallengeHashTagLabel(title: keyword)
            hashTagStack.addArrangedSubview(button)  // 새 버튼 추가
        }
    }
    
    public func setupChallengeReport(report: ChallengeReportDTO){
        creditNum.text = "\(report.totalCredits)"
        writtenDiaryNum.text = "\(report.totalDiaries)"
        diaryDatesLabel.text = "(\(report.diaryDate))"
        
    }
    
    public func setEmptyChallenge(isEmptyChallenge: Bool, isEmptyKeyword: Bool){
        challengePageContainer.isHidden = isEmptyChallenge
        emptyChallengeIcon.isHidden = !isEmptyChallenge
        emptyChallengeLabel.isHidden = !isEmptyChallenge
        hashTagStack.isHidden = isEmptyKeyword
        
        if(isEmptyChallenge && !isEmptyKeyword) {
            emptyChallengeLabel.text = "오늘의 챌린지가 존재하지 않습니다."
            emptyChallengeIcon.snp.updateConstraints {
                $0.top.equalTo(titleStack.snp.bottom).offset(80)
            }
            self.layoutIfNeeded()
        }
        
        if(isEmptyChallenge && isEmptyKeyword) {
            emptyChallengeLabel.text = "오늘의 일기를 작성하고 챌린지를 진행해 보세요!"
            emptyChallengeIcon.snp.updateConstraints {
                $0.top.equalTo(titleStack.snp.bottom).offset(80)
            }
            self.layoutIfNeeded()
        }
        
        challengeReportTitle.snp.remakeConstraints {
            $0.top.equalTo(challengePageContainer.snp.bottom)
            $0.left.equalToSuperview().offset(24)
        }
    }
    
    public func showChallenge(){
        todayChallengeCollectionView.isHidden = false
        emptyChallengeIcon.isHidden = true
        emptyChallengeLabel.isHidden = true
    }
    // MARK: - addFunction & Constraints
    
    private func addStacdk(){
        [title, subTitle].forEach(titleStack.addArrangedSubview)
        keywords.forEach{
            let keywordBox = makeChallengeHashTagLabel(title: $0)
            hashTagStack.addArrangedSubview(keywordBox)
        }
        [creditNumIcon, creditNum].forEach(creditNumStack1.addArrangedSubview)
        [creditNumLabel, creditNumStack1].forEach(creditNumStack2.addArrangedSubview)
        [writtenDiaryIcon, writtenDiaryNum, diaryDatesLabel].forEach(writtenDiaryStack1.addArrangedSubview)
        [writtenDiaryLabel, writtenDiaryStack1].forEach(writtenDiaryStack2.addArrangedSubview)
        [creditNumberContainer, writtenDiaryNumContainer].forEach(challengeReportContainerStack.addArrangedSubview)
        [emptyChallengeIcon, emptyChallengeLabel].forEach(emptyChallengeStack.addArrangedSubview)
        [todayChallengeCollectionView, pageControl].forEach(challengePageContainer.addArrangedSubview)
    }
    
    private func addComponents(){
        [titleStack, hashTagStack, challengePageContainer, emptyChallengeIcon, emptyChallengeLabel, challengeReportTitle, challengeReportSubTitle, challengeReportContainerStack].forEach(self.addSubview)
        
        creditNumberContainer.addSubview(creditNumStack2)
        writtenDiaryNumContainer.addSubview(writtenDiaryStack2)
    }
    
    private func constraints(){
        
        titleStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.left.equalToSuperview().offset(24)
        }
        
        hashTagStack.snp.makeConstraints{
            $0.top.equalTo(titleStack.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(24)
        }
        
        challengePageContainer.snp.makeConstraints {
            $0.top.equalTo(hashTagStack.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(160)
        }
        
        todayChallengeCollectionView.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.width.equalToSuperview().multipliedBy(0.88)
            $0.height.equalTo(130)
        }
    
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(12)
        }
        
        emptyChallengeIcon.snp.makeConstraints {
            $0.top.equalTo(titleStack.snp.bottom).offset(53)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        emptyChallengeLabel.snp.makeConstraints {
            $0.top.equalTo(emptyChallengeIcon.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(18)
        }
        
        challengeReportTitle.snp.makeConstraints {
            $0.top.equalTo(challengePageContainer.snp.bottom)
            $0.left.equalToSuperview().offset(24)
        }
        
        challengeReportSubTitle.snp.makeConstraints {
            $0.top.equalTo(challengeReportTitle.snp.bottom).offset(4)
            $0.left.equalToSuperview().offset(24)
        }
        
        creditNumIcon.snp.makeConstraints{
            $0.height.width.equalTo(28)
        }
        
        writtenDiaryIcon.snp.makeConstraints{
            $0.height.width.equalTo(28)
        }
        
        creditNumStack2.snp.makeConstraints{
            $0.verticalEdges.equalToSuperview().inset(20)
            $0.centerX.equalToSuperview()
        }
        
        writtenDiaryStack2.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(20)
            $0.centerX.equalToSuperview()
        }
        
        challengeReportContainerStack.snp.makeConstraints {
            $0.top.equalTo(challengeReportSubTitle.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
    }
    
}

class PaddingLabel: UILabel {
    var edgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: edgeInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + edgeInsets.left + edgeInsets.right,
            height: size.height + edgeInsets.top + edgeInsets.bottom
        )
    }
}


//import SwiftUI
//
//struct ChallengeHomeAreaView: View{
//
//    @State var items: [String] = ["즐거운", "차분한", "새로운"]
//    let todayChallenges : [RecommendedChallenge] = [
//        RecommendedChallenge(id: 0, title: "타이틀1", content: "좋아하는 책 독서하기", time: 60, type: "daily"),
//        RecommendedChallenge(id: 1, title: "타이틀2", content: "산책하기", time: 30, type: "daily"),
//        RecommendedChallenge(id: 2, title: "타이틀3", content: "명상하기", time: 120, type: "daily"),
//    ]
//
//    let report: ChallengeReportDTO = ChallengeReportDTO(totalCredits: 1200, totalDiaries: 16, diaryDate: "D+15")
//
//    var body: some View{
//        VStack(alignment: .leading){
//            Spacer().frame(height: 32)
//
//            DefaultLabel(title: "오늘의 챌린지", color: .black, font: .heading1Bold)
//
//            Spacer().frame(height: 4)
//
//            DefaultLabel(title: "나의 심리 정보를 기반으로 챌린지를 추천해요", color: .gray500, font: .body2Medium)
//
//            Spacer().frame(height: 20)
//
//            HStack(spacing: 8){
//                ForEach(items, id: \.self){ item in
//                    KeywordBox(title:item)
//                }
//            }
//
//            Spacer().frame(height: 8)
//
//            TodayChallengePagingView()
//
//            Spacer().frame(height: 32)
//
//            DefaultLabel(title: "그로의 챌린지 리포트", color: .gray900, font: .heading1Bold)
//
//            Spacer().frame(height: 4)
//
//            DefaultLabel(title: "그로우잇과 얼마나 성장했는지 확인해 보세요!", color: .gray500, font: .body2Medium)
//
//            Spacer().frame(height: 20)
//
//            HStack(spacing: 8){
//                CreditReportCard(title: "총 크레딧 수", totalCredit: report.totalCredits)
//                DiaryReportCard(title: "작성한 일기 수", totalDiaries: report.totalDiaries, dates: "(\(report.diaryDate))")
//            }
//        }
//        .padding(.horizontal, 24)
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//        .background(.gray50)
//    }
//}
//
//
//
//// MARK: - 감정 키워드 박스
//struct KeywordBox: View {
//    let title: String
//
//    init(title: String) {
//        self.title = title
//    }
//
//    var body: some View {
//
//        Text(title)
//            .styled(.body2SemiBold)
//            .foregroundStyle(.primary700)
//            .padding(.horizontal, 16)
//            .padding(.vertical, 6)
//
//            .background(.primary100)
//            .overlay(
//                RoundedRectangle(cornerRadius: 6)
//                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
//            )
//    }
//}
//
//// MARK: - 오늘의 챌린지 내용 뷰
//struct ChallengeCellView: View {
//    let challenge: RecommendedChallengeDTO
//    let completed: Bool
//    @State private var showModal: Bool = false
//
//    var body: some View {
//        HStack(spacing: 12) {
//            // 아이콘
//            Image("challengeIcon")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 40, height: 40)
//
//            // 중앙 컨텐츠 (제목 + 시간)
//            VStack(alignment: .leading, spacing: 8) {
//                // 제목
//                Text(challenge.title)
//                    .foregroundColor(.gray900)
//                    .styled(.heading3Bold)
//                    .lineLimit(nil)
//                    .multilineTextAlignment(.leading)
//                    .minimumScaleFactor(0.5)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//
//                // 시간 정보
//                HStack(spacing: 4) {
//                    Image("timeIcon")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 16, height: 16)
//
//                    Text(challenge.time.formattedTime)
//                        .foregroundColor(.primary600)
//                        .styled(.body2Medium)
//                }
//            }
//            .frame(maxWidth: .infinity)
//
//            Spacer()
//
//            // 버튼
//            Button(action: {showModal = true}) {
//                Text(completed ? "인증 완료" : "인증하기")
//                    .styled(.detail1Medium)
//                    .foregroundColor(completed ? .positive400 : .white)
//                    .minimumScaleFactor(0.8)
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 8)
//                    .frame(minWidth: completed ? 72 : 68)
//                    .background(completed ? .positive50 : .black)
//                    .cornerRadius(16)
//            }
//        }
//        .padding(.horizontal, 24)
//        .padding(.vertical, 24.5)
//        .frame(maxWidth: .infinity)
//        .background(.white)
//        .cornerRadius(20)
//        .overlay(
//            RoundedRectangle(cornerRadius: 20)
//                .stroke(Color.black.opacity(0.1), lineWidth: 1)
//        )
//        .sheet(isPresented: $showModal) {
//            // 실제 모달 컨텐츠
//            if #available(iOS 16.4, *) {
//                modalContent
//                    .presentationDetents(completed ? [.large] : [.height(358)])
//                    .presentationCornerRadius(40)
//                    .frame(maxWidth: .infinity)
//                    .background(.white)
//                    .transition(.move(edge: .bottom))
//            } else {
//                modalContent
//            }
//        }
//    }
//
//    @ViewBuilder
//    private var modalContent: some View {
//        if(completed){
//            ChallengeCompleteScreen()
//        }else{
//            ChallengeVerify()
//        }
//    }
//}
//
//// MARK: - 오늘의 챌린지 페이징 뷰
//struct TodayChallengePagingView: View {
//    let challenges : [RecommendedChallengeDTO] = [
//        RecommendedChallengeDTO(id: 0, title: "타이틀12345", content: "좋아하는 책 독서하기", dtype: "random", time: 60, completed: true),
//        RecommendedChallengeDTO(id: 1, title: "타이틀2", content: "산책하기", dtype: "random", time: 30, completed: false),
//        RecommendedChallengeDTO(id: 2, title: "타이틀3", content: "명상하기", dtype: "daily", time: 120, completed: true),
//    ]
//    @State private var currentIndex = 0
//
//    var body: some View {
//        VStack(spacing: 12) {
//            TabView(selection: $currentIndex) {
//                ForEach(challenges.indices, id: \.self) { index in
//                    ChallengeCellView(
//                        challenge: challenges[index],
//                        completed: challenges[index].completed
//                    )
//                    .frame(width: UIScreen.main.bounds.width - 48, height: 100)
//                    .tag(index)
//                }
//            }
//            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//            .frame(height: 100)
//
//            // 커스텀 페이지 인디케이터
//            PageIndicator(currentIndex: currentIndex, totalCount: challenges.count)
//        }
//    }
//
//}
//
//// MARK: - 페이지 인디케이터
//struct PageIndicator: View {
//    let currentIndex: Int
//    let totalCount: Int
//
//    var body: some View {
//        HStack(spacing: 8) {
//            ForEach(0..<totalCount, id: \.self) { index in
//                Circle()
//                    .fill(index == currentIndex ? .primary500 : .gray300)
//                    .frame(width: 8, height: 8)
//                    .scaleEffect(index == currentIndex ? 1.2 : 1.0)
//                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
//            }
//        }
//        .padding(.horizontal)
//    }
//}
//
//// MARK: - 크레딧 리포트 카드
//struct CreditReportCard: View {
//    let title: String
//    let totalCredit: Int
//
//    var body: some View {
//        VStack(alignment: .center, spacing: 8){
//            DefaultLabel(title: "\(title)", color: .gray500, font: .body2Medium)
//            HStack(spacing: 4){
//                Image("creditNumIcon")
//                    .resizable()
//                    .frame(width: 28, height: 28)
//                DefaultLabel(title: "\(totalCredit)", color: .gray900, font: .heading2Bold)
//            }
//        }
//        .padding(.vertical, 20)
//        .frame(maxWidth: .infinity)
//        .background(.white)
//        .clipShape(RoundedRectangle(cornerRadius: 20))
//        .overlay(
//            RoundedRectangle(cornerRadius: 20)
//                .stroke(Color.black.opacity(0.1), lineWidth: 1)
//        )
//    }
//}
//
//// MARK: - 일기 리포트 카드
//struct DiaryReportCard: View {
//    let title: String
//    let totalDiaries: Int
//    let dates: String
//
//    init(title: String, totalDiaries: Int, dates: String) {
//        self.title = title
//        self.totalDiaries = totalDiaries
//        self.dates = dates
//    }
//
//    var body: some View {
//        VStack(spacing: 8){
//            DefaultLabel(title: "\(title)", color: .gray500, font: .body2Medium)
//            HStack(spacing: 4){
//                Image("creditNumIcon")
//                    .resizable()
//                    .frame(width: 28, height: 28)
//                DefaultLabel(title: "\(totalDiaries)", color: .gray900, font: .heading2Bold)
//                DefaultLabel(title: "\(dates)", color: .gray400, font: .body2Medium)
//            }
//        }
//        .padding(.vertical, 20)
//        .frame(maxWidth: .infinity)
//        .background(.white)
//        .clipShape(RoundedRectangle(cornerRadius: 20))
//        .overlay(
//            RoundedRectangle(cornerRadius: 20)
//                .stroke(Color.black.opacity(0.1), lineWidth: 1)
//        )
//    }
//}
//
//struct ChallengeComplete: View {
//    var body: some View {
//        DefaultLabel(title: "챌린지 완료화면", color: .black, font: .heading1Bold)
//    }
//}
//
//struct ChallengeVerify: View {
//    var body: some View {
//        DefaultLabel(title: "챌린지 인증화면", color: .black, font: .heading1Bold)
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChallengeHomeAreaView()
//    }
//}
