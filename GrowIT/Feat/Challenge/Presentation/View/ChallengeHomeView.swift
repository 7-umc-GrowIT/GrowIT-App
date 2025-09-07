//
//  ChallengHomeView.swift
//  GrowIT
//
//  Created by 허준호 on 1/20/25.
//

import UIKit
import Then
import SnapKit

class ChallengeHomeView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addComponents()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Property
    
    private lazy var titleLabel = UILabel().then{
        $0.text = "챌린지"
        $0.textColor = .grayColor900
        $0.font = .title1Bold()
    }
    
    private lazy var settingBtn = UIButton().then {
        $0.setImage(UIImage(named: "setting"), for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    public lazy var challengeHomeBtn = makeButton(title: "홈")
    
    public lazy var challengeStatusBtn = makeButton(title: "챌린지 현황")
    
    public lazy var challengeSegmentUnderline = UIView().then{
        $0.backgroundColor = .primary600
        $0.layer.shouldRasterize = false
        $0.clipsToBounds = true
    }
    
    private lazy var divideLine = UIView().then{
        $0.backgroundColor = .black.withAlphaComponent(0.1)
    }
    
    // MARK: - Stack
    private lazy var challengeHomeNavbar = makeStack(axis: .horizontal, spacing: 0)
    
    private lazy var segmentBtnStack = makeStack(axis: .horizontal, spacing:24)
    
    // MARK: - Func
    private func makeStack(axis: NSLayoutConstraint.Axis, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.distribution = .equalSpacing
        return stackView
    }
    
    private func makeButton(title:String) -> UIButton {
        let button = UIButton()
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(.gray300, for: .normal)
        button.titleLabel?.font = .heading2SemiBold()
        return button
    }
    
    
    // MARK: - Property
    private func addComponents(){
        [challengeHomeNavbar, segmentBtnStack, challengeSegmentUnderline, divideLine].forEach(self.addSubview)
        [titleLabel, settingBtn].forEach(challengeHomeNavbar.addArrangedSubview)
        [challengeHomeBtn, challengeStatusBtn].forEach(segmentBtnStack.addArrangedSubview)
    }
    
    private func constraints(){
        
        settingBtn.snp.makeConstraints {
            $0.height.width.equalTo(36)
        }
        
        challengeHomeNavbar.snp.makeConstraints{
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalToSuperview().multipliedBy(0.07)
        }
        
        segmentBtnStack.snp.makeConstraints {
            $0.top.equalTo(challengeHomeNavbar.snp.bottom).offset(15)
            $0.left.equalToSuperview().offset(24)
        }
        
        challengeSegmentUnderline.snp.makeConstraints{
            $0.height.equalTo(1)
            $0.width.equalTo(3)
            $0.top.equalTo(segmentBtnStack.snp.bottom)
            $0.left.equalTo(segmentBtnStack.snp.left)
        }
        
        divideLine.snp.makeConstraints{
            $0.height.equalTo(1)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(challengeSegmentUnderline.snp.bottom)
        }
    }
    
    func updateUnderlinePosition(button: UIButton, animated: Bool) {
        let titleLabel = button.titleLabel!
        titleLabel.sizeToFit() // titleLabel의 크기를 콘텐츠에 맞게 조정
        
        challengeSegmentUnderline.snp.remakeConstraints {
            $0.top.equalTo(button.snp.bottom).offset(15)
            $0.height.equalTo(2)
            $0.centerX.equalTo(titleLabel.snp.centerX)
            $0.width.equalTo(titleLabel.snp.width)
        }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded() // 애니메이션 효과 추가
                self.challengeSegmentUnderline.setNeedsDisplay()
            }
        } else {
            self.layoutIfNeeded() // 애니메이션 없이 레이아웃 업데이트
            self.challengeSegmentUnderline.setNeedsDisplay()
        }
    }
    
}

//import SwiftUI
//import Combine
//
//struct ChallengeHomeScreen: View {
//    @State private var selectedTapIndex: Int = 0
//
//    var body: some View {
//        VStack(spacing: 0){
//            VStack{
//                ChallengeNavBar()
//                ChallengeTabBar(
//                    selectedIndex: $selectedTapIndex,
//                    onTap: { index in
//                        selectedTapIndex = index
//                    }
//                )
//            }
//            Rectangle()
//                .fill(.black.opacity(0.1))
//                .frame(height: 1)
//
//            // 선택된 탭에 따라 다른 뷰 표시
//            TabContentView(selectedIndex: selectedTapIndex)
//        }
//
//        .frame(maxWidth: .infinity, alignment: .top)
//
//    }
//}
//
//// MARK: - 상단 네비게이션 바
//struct ChallengeNavBar: View {
//    var body: some View {
//        HStack{
//            DefaultLabel(title: "챌린지", color: .gray900, font: .title1Bold)
//            Spacer()
//            Button(action:{
//
//            }){
//                Image("setting")
//                    .resizable()
//                    .frame(width: 38, height: 38)
//            }
//        }
//        .padding(.vertical, 13.5)
//        .padding(.horizontal, 24)
//    }
//}
//
//// MARK: - 탭 바(홈, 챌린지 현황)
//struct ChallengeTabBar: View {
//    @Binding var selectedIndex: Int
//    let onTap: (Int) -> Void
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            // 탭 버튼들
//            HStack(spacing: 24) {
//                TabItemView(
//                    title: "홈",
//                    isSelected: selectedIndex == 0,
//                    onTap: {
//                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                            selectedIndex = 0
//                        }
//                        onTap(0)
//                    }
//                )
//
//                TabItemView(
//                    title: "챌린지 현황",
//                    isSelected: selectedIndex == 1,
//                    onTap: {
//                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                            selectedIndex = 1
//                        }
//                        onTap(1)
//                    }
//                )
//            }
//            .padding(.horizontal, 24)
//
//            // 🎯 슬라이딩 밑줄 (별도 처리)
//            SlidingUnderline(selectedIndex: selectedIndex)
//                .frame(height: 2)
//        }
//    }
//}
//
//// 밑줄 없는 탭 아이템
//struct TabItemView: View {
//    let title: String
//    let isSelected: Bool
//    let onTap: () -> Void
//
//    var body: some View {
//        DefaultLabel(
//            title: title,
//            color: isSelected ? .primary600 : .gray400,
//            font: isSelected ? .heading2Bold : .heading2SemiBold
//        )
//        .padding(.vertical, 15)
//        .onTapGesture {
//            onTap()
//        }
//    }
//}
//
//// 🎯 슬라이딩 밑줄 컴포넌트
//struct SlidingUnderline: View {
//    let selectedIndex: Int
//    @State private var homeWidth: CGFloat = 0
//    @State private var statusWidth: CGFloat = 0
//
//    var body: some View {
//        HStack(spacing: 24) {
//            // 홈 영역 (너비 측정용)
//            Text("홈")
//                .styled(.heading2Bold)
//                .opacity(0) // 투명하게 해서 측정만
//                .background(
//                    GeometryReader { geometry in
//                        Color.clear.onAppear {
//                            homeWidth = geometry.size.width
//                        }
//                    }
//                )
//
//            // 챌린지 현황 영역 (너비 측정용)
//            Text("챌린지 현황")
//                .styled(.heading2Bold)
//                .opacity(0) // 투명하게 해서 측정만
//                .background(
//                    GeometryReader { geometry in
//                        Color.clear.onAppear {
//                            statusWidth = geometry.size.width
//                        }
//                    }
//                )
//
//            Spacer()
//        }
//        .overlay(alignment: .leading) {
//            // 🎯 실제 슬라이딩 밑줄
//            Rectangle()
//                .fill(.primary600)
//                .frame(
//                    width: selectedIndex == 0 ? homeWidth : statusWidth,
//                    height: 2
//                )
//                .offset(
//                    x: selectedIndex == 0 ? 0 : homeWidth + 24 // 24는 spacing
//                )
//                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedIndex)
//        }
//        .padding(.horizontal, 24)
//    }
//}
//
//// MARK: - 탭 콘텐츠 뷰
//struct TabContentView: View {
//    let selectedIndex: Int
//
//    var body: some View {
//        VStack {
//            switch selectedIndex {
//            case 0:
//                ChallengeHomeAreaView() // 🎯 홈 탭 뷰
//                    .transition(.opacity)
//            case 1:
//                ChallengeStatusAreaView() // 🎯 챌린지 현황 뷰
//                    .transition(.opacity)
//            default:
//                EmptyView()
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .animation(.easeInOut(duration: 0.3), value: selectedIndex)
//    }
//}
//
//struct ChallengeHomePreviews: PreviewProvider {
//    static var previews: some View {
//        ChallengeHomeScreen()
//    }
//}

