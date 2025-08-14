//
//  DiaryAllViewTableViewCell.swift
//  GrowIT
//
//  Created by 이수현 on 1/24/25.
//

import UIKit

protocol DiaryAllViewCellDelegate: AnyObject {
    func didTapButton(in cell: DiaryAllViewTableViewCell)
}

class DiaryAllViewTableViewCell: UITableViewCell {
    
    static let identifier = "DiaryAllViewTableViewCell"
    
    weak var delegate: DiaryAllViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        selectionStyle = .none
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 6.0, right: 0))
    }
    
    let contentLabel = UILabel().then {
        $0.text = "오늘은 평소보다 조금 더 차분한 하루를 보냈다. 아침에 일어나 창밖을 보니 햇살이 눈부시게 비치고 있었다. 차가운 겨울 공기 속에서도 따뜻한 햇살이 포근하게 느껴졌다. 오후에는 간단히 산책을 나갔다. 겨울 특유의 청량한 공기를 마시며 걷다 보니, 머릿속이 맑아지고 새로운 아이디어도 떠올랐다. 저녁에는 따뜻한 차 한 잔과 함께 하루를 정리하며 감사한 마음으로 마무리했다."
        $0.font = .body1Medium()
        $0.textColor = .gray900
        $0.numberOfLines = 0
    }
    
    private let vector = UIView().then {
        $0.backgroundColor = .border2
    }
    
    let dateLabel = UILabel().then {
        $0.text = "2025-01-24"
        $0.font = .body2Medium()
        $0.textColor = .gray500
    }
    
    let fixButton = UIButton().then {
        $0.setTitle("수정하기", for: .normal)
        $0.titleLabel?.font = .detail1Medium()
        $0.backgroundColor = .gray100
        $0.setTitleColor(.gray500, for: .normal)
        $0.layer.cornerRadius = 15
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 20
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.border2.cgColor
        
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            // make.height.equalTo(160)
        }
        
        contentView.addSubview(vector)
        vector.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(100)
            make.height.equalTo(1)
        }
        
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(vector.snp.top).offset(-12)
        }
        
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(vector.snp.leading)
            make.top.equalTo(vector.snp.bottom).offset(12)
        }
        
        contentView.addSubview(fixButton)
        fixButton.snp.makeConstraints { make in
            make.trailing.equalTo(vector.snp.trailing)
            make.top.equalTo(vector.snp.bottom).offset(12)
            make.bottom.equalToSuperview().inset(16)
            make.width.equalTo(73)
            make.height.equalTo(32)
        }
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(fixButton.snp.bottom).offset(16)
        }
    }
    
    private func setupActions() {
        fixButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
        delegate?.didTapButton(in: self) 
    }
    
}
