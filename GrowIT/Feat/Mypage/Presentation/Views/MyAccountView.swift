//
//  MyAccountView.swift
//  GrowIT
//
//  Created by 오현민 on 7/12/25.
//

import UIKit

class MyAccountView: UIView {
    //MARK: - Components
    public lazy var myAccounttableView = UITableView(frame: .zero, style: .grouped).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = false
    }
    
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    public lazy var logoutButton = SmallTextButton(title: "로그아웃")
    public lazy var withdrawButton = SmallTextButton(title: "회원탈퇴")
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - SetUI
    private func setView() {
        addSubviews([myAccounttableView, logoutButton, withdrawButton])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 테이블뷰의 contentSize에 맞게 높이 조정
        tableViewHeightConstraint?.constant = myAccounttableView.contentSize.height
    }
    
    private func setConstraints() {
        myAccounttableView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
        
        // 높이 제약은 NSLayoutConstraint로 따로 관리
        tableViewHeightConstraint = myAccounttableView.heightAnchor.constraint(equalToConstant: 100)
        tableViewHeightConstraint?.isActive = true
        
        logoutButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.bottom.equalTo(withdrawButton.snp.top).offset(-12)
        }
        
        withdrawButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(60)
        }
        
    }
}
