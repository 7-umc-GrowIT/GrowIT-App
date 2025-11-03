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
    
    // ScrollView 추가
    public lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
    }
    
    // ContentView 추가
    private lazy var contentView = UIView().then {
        $0.backgroundColor = .clear
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
        label.numberOfLines = 0 // 여러 줄 지원
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
        
        hashTagStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        keywords.forEach { keyword in
            let button = makeChallengeHashTagLabel(title: keyword)
            hashTagStack.addArrangedSubview(button)
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
        // ScrollView와 ContentView 추가
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 모든 컴포넌트를 contentView에 추가
        [titleStack, hashTagStack, challengePageContainer, emptyChallengeIcon, emptyChallengeLabel, challengeReportTitle, challengeReportSubTitle, challengeReportContainerStack].forEach(contentView.addSubview)
        
        creditNumberContainer.addSubview(creditNumStack2)
        writtenDiaryNumContainer.addSubview(writtenDiaryStack2)
    }
    
    private func constraints(){
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        
        titleStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
        
        hashTagStack.snp.makeConstraints{
            $0.top.equalTo(titleStack.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(24)
            $0.right.lessThanOrEqualToSuperview().offset(-24)
        }
        
        challengePageContainer.snp.makeConstraints {
            $0.top.equalTo(hashTagStack.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(160)
        }
        
        todayChallengeCollectionView.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(24)
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
            $0.right.equalToSuperview().offset(-24)
        }
        
        challengeReportSubTitle.snp.makeConstraints {
            $0.top.equalTo(challengeReportTitle.snp.bottom).offset(4)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
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
            // contentView의 마지막 요소이므로 bottom 제약 추가
            $0.bottom.equalToSuperview().offset(-24)
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
