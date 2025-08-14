//
//  HomeView.swift
//  GrowIT
//
//  Created by 허준호 on 1/7/25.
//

import UIKit
import Then
import SnapKit

class HomeView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        addComponents()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Property
    
    // 상단 네비게이션 바
    lazy var topNavBar = HomeTopNavbarView()

    
    // 하단 캐릭터 영역
    var characterArea = HomeCharacterView()
    
    
    // MARK: - Function
    
    
    // MARK: - add Function & Constraints
    
    private func addComponents(){
        [topNavBar, characterArea].forEach(self.addSubview)
    }
    
    private func constraints(){
        
        topNavBar.snp.makeConstraints{
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            $0.height.equalToSuperview().multipliedBy(0.065)
        }
        
        characterArea.snp.makeConstraints{
            $0.top.equalTo(topNavBar.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
       
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        topNavBar.snp.makeConstraints{
            $0.left.equalToSuperview().offset(self.frame.width * 0.05)
            $0.right.equalToSuperview().inset(self.frame.width * 0.05)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsUpdateConstraints()
    }

}
