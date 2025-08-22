//
//  SmallTextButton.swift
//  GrowIT
//
//  Created by 오현민 on 6/9/25.
//

import UIKit

class SmallTextButton: UIButton {
    init(
        title: String,
        titleColor: UIColor = .gray400,
        font: UIFont = .body2Medium()
    ){
        super.init(frame: .zero)
        self.backgroundColor = .clear
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = font
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var underlineView: UIView?
    
    /// 밑줄을 표시하거나 숨기는 함수
    func setUnderline(_ show: Bool) {
        // 기존 밑줄 제거
        underlineView?.removeFromSuperview()
        underlineView = nil
        guard show, let titleLabel = self.titleLabel else { return }
        let underline = UIView()
        underline.backgroundColor = self.titleColor(for: .normal) ?? .black
        underline.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(underline)
        underlineView = underline
        NSLayoutConstraint.activate([
            underline.heightAnchor.constraint(equalToConstant: 1),
            underline.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            underline.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2)
        ])
    }
}
