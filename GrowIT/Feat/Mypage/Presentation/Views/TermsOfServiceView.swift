//
//  TermsOfServiceView.swift
//  GrowIT
//
//  Created by 오현민 on 8/29/25.
//

import UIKit

class TermsOfServiceView: UIView {
    
    // MARK: - Data
    var contents: String = "" {
        didSet {
            contentLabel.text = contents
        }
    }
    
    // MARK: - Components
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    
    public lazy var contentLabel = AppLabel(
        text: contents,
        font: .body2SemiBold(),
        textColor: .gray600
    ).then {
        $0.numberOfLines = 0
    }
    
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
    
    // MARK: - SetUI
    private func setView() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentLabel)
    }
    
    private func setConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide) // 🔥 가로 스크롤 안 생기게
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-32) // 🔥 끝까지 스크롤 가능하게
        }
    }
}
