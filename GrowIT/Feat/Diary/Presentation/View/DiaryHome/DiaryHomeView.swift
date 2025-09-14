//
//  JDiaryHomeView.swift
//  GrowIT
//
//  Created by 허준호 on 1/14/25.
//

import UIKit
import SnapKit

class DiaryHomeView: UIView {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addComponents()
        addStack()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Property
    
    // 일기 홈화면 스크롤뷰
    public lazy var diaryHomeScrollView = UIScrollView(frame: .zero).then{
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    public let contentView = UIView()
    
    // 일기 홈화면 상단 네비게이션바
    public lazy var diaryHomeNavbar = DiaryHomeNavbar()
    
    // 일기 홈화면 배너
    public lazy var diaryHomeBanner = DiaryHomeBanner()
    
    // 캘린더 헤더
    lazy var diaryHomeCalendarHeader = DiaryHomeCalendarHeader()

    // 일기 홈화면 스택 뷰
    public lazy var diaryHomeStack = makeStack()
    

    // MARK: - Function
    private func makeStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
    // MARK: - add Function & Constraints
    
    private func addStack(){
        
    }
    
    private func addComponents(){
        [diaryHomeNavbar, diaryHomeScrollView].forEach(self.addSubview)
        diaryHomeScrollView.addSubview(contentView)
        contentView.addSubviews([diaryHomeBanner, diaryHomeCalendarHeader])
    }
    
    private func constraints(){
        
        diaryHomeNavbar.snp.makeConstraints{
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.07)
        }
        
        diaryHomeScrollView.snp.makeConstraints{
            $0.top.equalTo(diaryHomeNavbar.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        diaryHomeBanner.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(444)
        }
        
        diaryHomeCalendarHeader.snp.makeConstraints{
            $0.top.equalTo(diaryHomeBanner.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(109)
        }
    }


}
