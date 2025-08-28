//
//  TermsOfServiceView.swift
//  GrowIT
//
//  Created by 오현민 on 8/29/25.
//

import UIKit

class TermsOfServiceView: UIView {
    
    //MARK: - Data
    var contents: String = """
    • 앱의 콘텐츠 및 기능은 저작권 보호를 받으며 무단 도용을 금합니다.\n
    • 이용자는 선의의 목적과 법령에 따라 서비스를 이용해야 합니다.\n 
    • 회사는 서비스의 안정적인 제공을 위해 일부 기능을 변경하거나 중단할 수 있습니다.\n
    • 이용 약관 및 정책은 사전 고지 후 변경될 수 있으며, 계속 사용 시 동의한 것으로 간주됩니다.\n
    """
    
    //MARK: - Components
    public lazy var contentLabel = UILabel().then {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.headIndent = 8
        
        let attrString = NSMutableAttributedString(
            string: contents,
            attributes: [
                .font: UIFont.body2SemiBold(),
                .foregroundColor: UIColor.gray600,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        $0.numberOfLines = 0
        $0.attributedText = attrString
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
    
    //MARK: - SetUI
    private func setView() {
        addSubview(contentLabel)
    }
    
    private func setConstraints() {
        contentLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.top.equalTo(safeAreaLayoutGuide).inset(32)
        }
    }
}
