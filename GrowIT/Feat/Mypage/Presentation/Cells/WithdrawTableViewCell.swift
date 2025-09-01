//
//  WithdrawTableViewCell.swift
//  GrowIT
//
//  Created by 오현민 on 8/30/25.
//

import UIKit

class WithdrawTableViewCell: UITableViewCell {
    static let identifier = "WithdrawTableViewCell"

    //MARK: - Components
    private lazy var mainLabel = AppLabel(text: "",
                                          font: .body1Medium(),
                                           textColor: .gray900)
    
    private lazy var separatorView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.1)
    }
    
    //MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        setView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - SetUI
    private func setView() {
        self.contentView.addSubviews([mainLabel, separatorView])
    }
    
    private func setConstraints() {
        mainLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
        
        separatorView.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    //MARK: - Configure
    func configure(mainText: String) {
        mainLabel.text = mainText
    }
}
