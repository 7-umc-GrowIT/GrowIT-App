//
//  ItemListModalView.swift
//  GrowIT
//
//  Created by 오현민 on 1/8/25.
//
// MARK: - 아이템 목록 ModalView

import UIKit

class ItemListModalView: UIView {
    
    var itemSegmentedControl = ItemTabSegmentedControl(items: [
        UIImage(named: "GrowIT_Background_On")!.withRenderingMode(.alwaysOriginal),
        UIImage(named: "GrowIT_Object_Off")!.withRenderingMode(.alwaysOriginal),
        UIImage(named: "GrowIT_FlowerPot_Off")!.withRenderingMode(.alwaysOriginal),
        UIImage(named: "GrowIT_Accessories_Off")!.withRenderingMode(.alwaysOriginal)
    ]).then {
        $0.selectedSegmentIndex = 0
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
        $0.register(MyItemCollectionViewCell.self, forCellWithReuseIdentifier: MyItemCollectionViewCell.identifier)
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
    
    //MARK: - 컴포넌트추가
    private func setView() {
        self.addSubviews([itemSegmentedControl, itemCollectionView, purchaseButton])
    }
    
    //MARK: - 레이아웃설정
    private func setConstraints() {
        itemSegmentedControl.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(30)
            $0.right.equalToSuperview().inset(30)
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.height.equalTo(92)
        }
        
        itemCollectionView.snp.makeConstraints {
            $0.top.equalTo(itemSegmentedControl.snp.bottom)
            $0.bottom.equalTo(purchaseButton.snp.top).offset(-16)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        purchaseButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }
    }
    
    func updateCollectionViewConstraints(forSuperviewInset inset: CGFloat) {
        itemCollectionView.snp.updateConstraints {
            $0.bottom.equalTo(purchaseButton.snp.top).offset(inset)
        }
        self.layoutIfNeeded()
    }
}

