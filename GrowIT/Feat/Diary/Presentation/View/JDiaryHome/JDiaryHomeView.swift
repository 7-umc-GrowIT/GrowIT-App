//
//  JDiaryHomeView.swift
//  GrowIT
//
//  Created by 허준호 on 1/14/25.
//

import UIKit
import SnapKit

class JDiaryHomeView: UIView {

    
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
    public lazy var diaryHomeScrollView = UIScrollView().then{
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    // 일기 홈화면 상단 네비게이션바
    private lazy var diaryHomeNavbar = JDiaryHomeNavbar()
    
    // 일기 홈화면 배너
    public lazy var diaryHomeBanner = JDiaryHomeBanner()
    
    // 캘린더 헤더
    lazy var diaryHomeCalendarHeader = JDiaryHomeCalendarHeader()
    
    // 캘린더
    public lazy var diaryHomeCalendar = JDiaryCalendar()

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
        diaryHomeScrollView.addSubview(diaryHomeStack)
        [diaryHomeBanner, diaryHomeCalendarHeader].forEach(diaryHomeStack.addArrangedSubview)
    }
    
    private func constraints(){
        
        diaryHomeNavbar.snp.makeConstraints{
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.065)
        }
        
        diaryHomeScrollView.snp.makeConstraints{
            $0.top.equalTo(diaryHomeNavbar.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            // 높이의 17% 값을 계산하여 bottom inset으로 사용
            let bottomInset = self.frame.size.height * 0.17
            $0.bottom.equalToSuperview().inset(bottomInset)
            //$0.bottom.equalToSuperview()
        }
        
        diaryHomeStack.snp.makeConstraints{
            $0.horizontalEdges.top.equalToSuperview()
            $0.bottom.equalToSuperview().inset(165)
            $0.width.equalTo(diaryHomeScrollView.snp.width)
        }

        
        diaryHomeBanner.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(444)
        }
        
        diaryHomeCalendarHeader.snp.makeConstraints{
            $0.height.equalToSuperview().multipliedBy(0.125)
            $0.horizontalEdges.equalToSuperview()
            //$0.bottom.equalTo(diaryHomeStack.snp.bottom)
        }

    }


}
