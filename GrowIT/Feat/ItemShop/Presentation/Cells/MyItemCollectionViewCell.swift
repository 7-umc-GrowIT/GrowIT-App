//
//  MyItemCollectionViewCell.swift
//  GrowIT
//
//  Created by 오현민 on 1/26/25.
//

import UIKit

class MyItemCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "IsOwnedItemCollectionViewCell"
    
    // 아이템 이미지
    var itemImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // 아이템 배경(색상)
    var itemBackGroundView = UIView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // 보유 중 라벨
    var isOwnedLabel = UILabel().then {
        $0.textColor = .grayColor500
        $0.font = UIFont.body2Medium()
        $0.textAlignment = .center
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .grayColor50
        self.layer.cornerRadius = 16
        
        setView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool{
        didSet {
            updateSelectionState()
        }
    }
    
    func updateSelectionState() {
        if isSelected {
            self.layer.borderWidth = 1.5
            self.layer.borderColor = UIColor.primary400.cgColor
            self.layer.shadowColor = UIColor.primary400.cgColor
            self.layer.shadowOpacity = 0.2
            self.layer.shadowRadius = 4
            self.layer.shadowOffset = CGSize(width: 0, height: 0)
            self.isOwnedLabel.text = "착용 중"
        } else {
            self.layer.borderWidth = 0
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.shadowColor = UIColor.clear.cgColor
            self.isOwnedLabel.text = "보유 중"
        }
    }
    //MARK: - 컴포넌트 추가
    private func setView() {
        itemBackGroundView.addSubview(itemImageView)
        self.addSubviews([itemBackGroundView, isOwnedLabel])
    }
    
    //MARK: - 레이아웃 설정
    private func setConstraints() {
        itemBackGroundView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(8)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(itemBackGroundView.snp.width).multipliedBy(84.0 / 106.0)
        }
        
        itemImageView.snp.makeConstraints {
            $0.size.equalToSuperview()
            $0.center.equalToSuperview()
        }
        
        isOwnedLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(15)
        }
        
    }
}
