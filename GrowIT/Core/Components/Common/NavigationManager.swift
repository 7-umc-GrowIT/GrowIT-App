//
//  NavigationManager.swift
//  GrowIT
//
//  Created by 이수현 on 1/12/25.
//

import Foundation
import UIKit
import SnapKit

class NavigationManager {
    
    init() {
    }
    
    // MARK: - 왼쪽 커스텀 백버튼 생성
    func addBackButton(to navigationItem: UINavigationItem, target: Any?, action: Selector, tintColor: UIColor = .label) {
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = tintColor
        backButton.addTarget(target, action: action, for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    // MARK: - 네비게이션 타이틀 생성
    func setTitle(to navigationItem: UINavigationItem, title: String, textColor: UIColor = .label, font: UIFont = UIFont.heading1Bold()) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = font
        titleLabel.textColor = textColor
        titleLabel.textAlignment = .center
        
        navigationItem.titleView = titleLabel
    }
    
    // MARK: - 네비게이션 바 하단 라인 추가
    func addBottomLine(to navigationBar: UINavigationBar) {
        // 이미 추가된 라인이 있으면 중복 추가 방지
        if navigationBar.viewWithTag(9999) != nil { return }
        
        let line = UIView()
        line.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.tag = 9999
        navigationBar.addSubview(line)
        line.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
