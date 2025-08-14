//
//  ItemCollectionViewCell.swift
//  GrowIT
//
//  Created by 오현민 on 1/9/25.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    static let identifier = "ItemCollectionViewCell"
    
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
    
    private lazy var creditStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 8
        $0.distribution = .equalSpacing
    }
    
    private lazy var creditIcon = UIImageView().then {
        $0.image = UIImage(named: "GrowIT_Credit")
        $0.contentMode = .scaleAspectFill
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var creditLabel = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.body2SemiBold()
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
            if isSelected {
                self.layer.borderWidth = 1.5
                self.layer.borderColor = UIColor.primary400.cgColor
                self.layer.shadowColor = UIColor.primary400.cgColor
                self.layer.shadowOpacity = 0.2
                self.layer.shadowRadius = 4
                self.layer.shadowOffset = CGSize(width: 0, height: 0)
            } else {
                self.layer.borderColor = UIColor.clear.cgColor
                self.layer.shadowColor = UIColor.clear.cgColor
            }
        }
    }
    
    //MARK: - 컴포넌트 추가
    private func setView() {
        itemBackGroundView.addSubview(itemImageView)
        creditStackView.addArrangedSubViews([creditIcon, creditLabel])
        self.addSubviews([itemBackGroundView, creditStackView])
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
        
        creditStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(15)
        }
        
        creditIcon.snp.makeConstraints {
            $0.width.equalTo(15)
            $0.height.equalTo(17)
        }
    }
    
}
