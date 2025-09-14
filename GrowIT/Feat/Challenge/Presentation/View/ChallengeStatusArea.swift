//
//  ChallengStatusArea.swift
//  GrowIT
//
//  Created by 허준호 on 1/22/25.
//

import UIKit
import Then
import SnapKit

class ChallengeStatusArea: UIView {
    
    let challengeStatusCateogry : [String] = ["전체", "완료", "랜덤 챌린지", "데일리 챌린지"]
    
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
    private lazy var challengeAllBtn = makeButton(title: "전체")
    
    private lazy var challengeFinishBtn = makeButton(title: "완료")
    
    private lazy var challengeRandomBtn = makeButton(title: "랜덤 챌린지")
    
    private lazy var challengeDailyBtn = makeButton(title: "데일리 챌린지")
    
    public lazy var challengeStatusBtnGroup = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then{
        $0.minimumInteritemSpacing = 8
        $0.scrollDirection = .horizontal
    }).then{
        $0.backgroundColor = .clear
        $0.register(ChallengeStatusBtnGroupCell.self, forCellWithReuseIdentifier: ChallengeStatusBtnGroupCell.identifier)
        $0.showsHorizontalScrollIndicator = false
    }
    
    private lazy var challengeStatusLabel = makeLabel(title: "챌린지 현황", color: .gray800, font: .body2Medium())
    
    
    public lazy var challengeStatusNum = makeLabel(title: "4", color: .primary700, font: .body2SemiBold())
    
    public lazy var challengeAllList = UITableView(frame: .zero, style: .plain).then {
        $0.register(CustomChallengeListCell.self, forCellReuseIdentifier: CustomChallengeListCell.identifier)
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = true
        $0.isScrollEnabled = true
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 100

    }
    
    // 페이징 컨트롤 관련 UI
    private lazy var pagingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    // 현재 페이지 (예시용)
    var currentPage: Int = 1 {
        didSet {
            updatePagingUI()
        }
    }
    var totalPage: Int = 5 {
        didSet {
            updatePagingUI()
        }
    }
    
    // 현재 페이지 묶음의 첫 번째 번호 (1, 6, 11, ...)
    private var pageGroupStart: Int {
        // 예: currentPage = 7이면 6
        return ((currentPage - 1) / 5) * 5 + 1
    }
    private var pageGroupEnd: Int {
        return min(pageGroupStart + 4, totalPage)
    }
    
    // MARK: - Func
    private lazy var challengeStatusBtnStack = makeStack(axis: .horizontal, spacing: 8)
    
    private lazy var challengeStatusLabelStack = makeStack(axis: .horizontal, spacing: 4)
    
    // MARK: - Func
    
    private func makeLabel(title:String, color: UIColor, font: UIFont) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textColor = color
        label.font = font
        return label
    }
    
    private func makeButton(title:String) -> UIButton{
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.gray300, for: .normal)
        button.titleLabel?.font = .heading3SemiBold()
        button.titleLabel?.numberOfLines = 1
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        
        return button
    }
    
    private func makeStack(axis: NSLayoutConstraint.Axis, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.distribution = .fillProportionally
        return stackView
    }
    
    public func statusBtnTapped(){
        
    }
    
    // 페이지 선택 콜백
    var onPageSelected: ((Int) -> Void)?
    
    // MARK: - Paging UI 생성
    private func updatePagingUI() {
        pagingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if totalPage < 1 || pageGroupStart > pageGroupEnd {
            return
        }
        
        let showPrevNext = totalPage > 5
        
        // 이전 페이지 그룹 버튼
        if showPrevNext && pageGroupStart > 1 {
            let prevButton = makePageButton("〈", isActive: true)
            prevButton.addTarget(self, action: #selector(prevPageGroupTapped), for: .touchUpInside)
            pagingStackView.addArrangedSubview(prevButton)
        }
        
        // 5개씩 페이지 번호
        for i in pageGroupStart...pageGroupEnd {
            let isCurrent = (i == currentPage)
            let pageBtn = makePageButton("\(i)", isActive: isCurrent)
            pageBtn.tag = i
            pageBtn.addTarget(self, action: #selector(pageTapped(_:)), for: .touchUpInside)
            pagingStackView.addArrangedSubview(pageBtn)
        }
        
        // 다음 페이지 그룹 버튼
        if showPrevNext && pageGroupEnd < totalPage {
            let nextButton = makePageButton("〉", isActive: true)
            nextButton.addTarget(self, action: #selector(nextPageGroupTapped), for: .touchUpInside)
            pagingStackView.addArrangedSubview(nextButton)
        }
    }
    
    
    private func makePageButton(_ title: String, isActive: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .body2Medium()
        button.layer.cornerRadius = 8
        
        // 페이지 번호 버튼
        if let _ = Int(title) {
            button.layer.borderWidth = isActive ? 0 : 0
            button.layer.borderColor = UIColor.clear.cgColor
            button.backgroundColor = isActive ? UIColor.primary500 : .clear
            button.setTitleColor(isActive ? .white : .gray300, for: .normal)
        } else {
            button.backgroundColor = .gray200
            button.setTitleColor(.white, for: .normal)
        }
        
        button.snp.makeConstraints { $0.width.height.equalTo(24) }
        return button
    }
    
    
    // MARK: - 페이지 버튼 액션 (예시)
    @objc private func prevPageGroupTapped() {
        // 이전 5개 그룹의 첫 페이지로 이동
        let prevStart = max(pageGroupStart - 5, 1)
        if currentPage != prevStart {
            onPageSelected?(prevStart)
        }
    }
    
    @objc private func nextPageGroupTapped() {
        // 다음 5개 그룹의 첫 페이지로 이동
        let nextStart = min(pageGroupStart + 5, totalPage)
        if currentPage != nextStart {
            onPageSelected?(nextStart)
        }
    }
    
    
    @objc private func pageTapped(_ sender: UIButton) {
        let page = sender.tag
        if page != currentPage {
            onPageSelected?(page)
        }
    }
    
    
    // MARK: - addFunc & Constraints
    
    private func addStack(){
        [challengeAllBtn, challengeFinishBtn, challengeRandomBtn, challengeDailyBtn].forEach(challengeStatusBtnStack.addArrangedSubview)
        
        [challengeStatusLabel, challengeStatusNum].forEach(challengeStatusLabelStack.addArrangedSubview)
    }
    
    private func addComponents(){
        [challengeStatusBtnGroup, challengeStatusLabelStack, challengeAllList, pagingStackView].forEach(self.addSubview)
    }
    
    private func constraints(){
        
        challengeStatusBtnGroup.snp.makeConstraints{
            $0.top.equalToSuperview().offset(28)
            $0.left.equalToSuperview().offset(24)
            $0.height.equalTo(40)
            $0.right.greaterThanOrEqualToSuperview()
        }
        
        challengeStatusLabelStack.snp.makeConstraints{
            $0.top.equalTo(challengeStatusBtnGroup.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(24)
        }
        
        challengeAllList.snp.makeConstraints{
            $0.top.equalTo(challengeStatusLabelStack.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(24)
            
        }
        
        pagingStackView.snp.makeConstraints {
            $0.top.equalTo(challengeAllList.snp.bottom).offset(60)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
            $0.bottom.equalToSuperview().inset(65 + 100)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let flowLayout = challengeStatusBtnGroup.collectionViewLayout as? UICollectionViewFlowLayout {
            let totalSpacing = flowLayout.minimumInteritemSpacing * CGFloat(challengeStatusCateogry.count - 1)
            let itemWidth = (challengeStatusBtnGroup.bounds.width - totalSpacing) / CGFloat(challengeStatusCateogry.count)
            flowLayout.itemSize = CGSize(width: itemWidth, height: 40)
        }
    }
}

//import SwiftUI
//
//struct ChallengeStatusAreaView: View {
//    let totalChallenges: Int = 4
//
//    var body: some View {
//        VStack(alignment: .leading){
//            Spacer().frame(height: 28)
//            CategoryBtnGroup()
//            Spacer().frame(height: 16)
//            HStack(spacing: 4){
//                DefaultLabel(title: "챌린지 현황", color: .gray600, font: .body2Medium)
//                DefaultLabel(title: "\(totalChallenges)", color: .primary700, font: .body2SemiBold)
//            }
//            Spacer().frame(height: 12)
//
//        }
//        .padding(.horizontal, 24)
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//        .background(.gray50)
//    }
//}
//
//// MARK: - 카테고리 버튼 그룹
//struct CategoryBtnGroup: View {
//    let categories: [String] = ["전체", "완료", "랜덤 챌린지", "데일리 챌린지"]
//    @State private var selectedIndex: Int = 0
//
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false){
//            HStack(spacing: 8){
//                ForEach(Array(categories.enumerated()), id: \.offset) { index, category in
//                    CategoryButton(
//                        title: category,
//                        isSelected: selectedIndex == index, // 🎯 인덱스로 비교
//                        onTap: {
//                            selectedIndex = index // 🎯 인덱스 직접 설정
//                        }
//                    )
//                }
//            }
//        }
//    }
//}
//
//// MARK: - 카테고리 버튼
//struct CategoryButton: View {
//    let title: String
//    let isSelected: Bool
//    let onTap: () -> Void
//
//    init(title: String, isSelected: Bool, onTap: @escaping () -> Void) {
//        self.title = title
//        self.isSelected = isSelected
//        self.onTap = onTap
//    }
//
//    var body: some View {
//        Button(action: onTap){
//            DefaultLabel(title: "\(title)", color: isSelected ? .primary700 : .gray300, font: .heading3Bold)
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 9)
//        .background(isSelected ? .primary100 : .white)
//        .clipShape(RoundedRectangle(cornerRadius: 6))
//        .overlay{
//            RoundedRectangle(cornerRadius: 6)
//                .stroke(.black.opacity(0.1), lineWidth: 1)
//        }
//
//    }
//}
//
//struct ChallengeStatusAreaView_Preview: PreviewProvider {
//    static var previews: some View {
//        ChallengeStatusAreaView()
//    }
//}
