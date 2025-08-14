//
//  ItemBackgroundModalView.swift
//  GrowIT
//
//  Created by 오현민 on 1/12/25.
//

import UIKit

class ItemBackgroundModalView: UIView {
    private lazy var backgroundIcon = UIImageView().then {
        $0.image = UIImage(named: "GrowIT_Background_On")
        $0.contentMode = .scaleAspectFill
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var itemCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.minimumInteritemSpacing = 8
        $0.minimumInteritemSpacing = 8
        $0.scrollDirection = .vertical
    }).then {
        $0.isScrollEnabled = true
        $0.showsVerticalScrollIndicator = false
        $0.register(ItemCollectionViewCell.self, forCellWithReuseIdentifier: ItemCollectionViewCell.identifier)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public var purchaseButton = PurchaseButton(credit: 0).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
       
        configure()
        setView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        self.layer.cornerRadius = 40
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.15
        self.layer.shadowRadius = 9
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    //MARK: - 컴포넌트 추가
    private func setView() {
        self.addSubviews([backgroundIcon, itemCollectionView, purchaseButton])
    }
    
    //MARK: - 레이아웃 설정
    private func setConstraints() {
        backgroundIcon.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        itemCollectionView.snp.makeConstraints {
            $0.top.equalTo(backgroundIcon.snp.bottom).offset(24)
            $0.bottom.equalTo(purchaseButton.snp.top).offset(-16)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        purchaseButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }
    }

}
