//
//  ItemListModalViewController.swift
//  GrowIT
//
//  Created by 오현민 on 1/8/25.
//

import UIKit
import Kingfisher

class ItemListModalViewController: UIViewController {
    // MARK: Properties
    let itemService = ItemService()
    weak var itemDelegate: ItemListDelegate?
    
    var currentCredit: Int = 0
    private var isMyItems: Bool = false
    private var category: String = "BACKGROUND"
    private var selectedItem: ItemList?
    
    private var myItems: [ItemList] = []
    private var shopItems: [ItemList] = []
    
    private lazy var currentSegmentIndex: Int = 0 {
        didSet { itemListModalView.itemCollectionView.reloadData() }
    }
    
    // MARK: Data
    private let categories: [String] = ["BACKGROUND", "OBJECT", "PLANT", "HEAD_ACCESSORY"]
    
    private let selectedImages: [UIImage] = [
        UIImage(named: "GrowIT_Background_On")!,
        UIImage(named: "GrowIT_Object_On")!,
        UIImage(named: "GrowIT_FlowerPot_On")!,
        UIImage(named: "GrowIT_Accessories_On")!
    ]
    private let defaultImages: [UIImage] = [
        UIImage(named: "GrowIT_Background_Off")!,
        UIImage(named: "GrowIT_Object_Off")!,
        UIImage(named: "GrowIT_FlowerPot_Off")!,
        UIImage(named: "GrowIT_Accessories_Off")!
    ]
    
    let colorMapping: [String: UIColor] = [
        "green": .itemGreen,
        "pink": .itemPink,
        "yellow": .itemYellow
    ]
    
    //MARK: - Views
    public lazy var itemListModalView = ItemListModalView().then {
        $0.itemSegmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        $0.purchaseButton.addTarget(self, action: #selector(didTapPurchaseButton), for: .touchUpInside)
    }
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = itemListModalView
        
        setDelegate()
        callGetItems()
        setNotification()
    }
    
    // MARK: - NetWork
    func callGetItems(completion: (() -> Void)? = nil) {
        itemService.getItemList(category: category) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                // 불러온 아이템 매핑
                self.shopItems = data.itemList
                self.myItems = data.itemList.filter { $0.purchased }
                
                DispatchQueue.main.async {
                    self.itemListModalView.itemCollectionView.reloadData()
                    
                    //  아이템 로딩이 끝난 뒤 현재 모드에 맞게 착용 중 표시
                    self.updateToMyItems(self.isMyItems)
                    
                    completion?()
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion?()
            }
        }
    }
    
    
    //MARK: - Delegate Method
    private func setDelegate() {
        itemListModalView.itemCollectionView.dataSource = self
        itemListModalView.itemCollectionView.delegate = self
    }
    
    //MARK: - Functional
    func updateToMyItems(_ isMyItems: Bool) {
        self.isMyItems = isMyItems
        itemListModalView.itemCollectionView.reloadData()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // 먼저 모든 선택 해제
            for indexPath in self.itemListModalView.itemCollectionView.indexPathsForSelectedItems ?? [] {
                self.itemListModalView.itemCollectionView.deselectItem(at: indexPath, animated: false)
            }
            
            if let delegate = self.itemDelegate as? GroViewController {
                let equippedIds = delegate.categoryToEquippedId
                let equippedNames = delegate.categoryToEquippedName
                
                let items: [ItemList]
                if isMyItems { items = myItems } else { items = shopItems }
                
                for (index, item) in items.enumerated() {
                    if equippedNames[item.category] == item.name {
                        let indexPath = IndexPath(item: index, section: 0)
                        self.itemListModalView.itemCollectionView.selectItem(
                            at: indexPath,
                            animated: false,
                            scrollPosition: []
                        )
                    }
                }
            }
        }
        
        itemListModalView.purchaseButton.isHidden = true
        let inset: CGFloat = 100
        itemListModalView.updateCollectionViewConstraints(forSuperviewInset: inset)
    }
    
    //MARK: Notification
    private func setNotification() {
        let Notification = NotificationCenter.default
        
        Notification.addObserver(self, selector: #selector(didCompletePurchase), name: .purchaseCompleted, object: nil)
    }
    
    @objc
    func didCompletePurchase(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let itemId = userInfo["itemId"] as? Int,
              let category = userInfo["category"] as? String else { return }
        
        // ✅ 로컬 equippedName 업데이트
        if let delegate = itemDelegate as? GroViewController {
            if let purchasedItem = (shopItems + myItems).first(where: { $0.id == itemId }) {
                delegate.categoryToEquippedName[category] = purchasedItem.name
            }
        }
        
        // ✅ 해당 카테고리 셀들만 갱신
        let items = isMyItems ? myItems : shopItems
        var reloadIndexPaths: [IndexPath] = []
        for (i, obj) in items.enumerated() where obj.category == category {
            reloadIndexPaths.append(IndexPath(item: i, section: 0))
        }
        itemListModalView.itemCollectionView.reloadData()
        
        itemListModalView.purchaseButton.isHidden = true
        callGetItems()
    }
    
    //MARK: Event
    @objc
    private func segmentChanged(_ segment: UISegmentedControl) {
        // 화면전환
        for index in 0..<segment.numberOfSegments {
            segment.setImage(
                defaultImages[index].withRenderingMode(.alwaysOriginal),
                forSegmentAt: index
            )
        }
        
        let selectedIndex = segment.selectedSegmentIndex
        segment.setImage(
            selectedImages[selectedIndex].withRenderingMode(.alwaysOriginal),
            forSegmentAt: selectedIndex
        )
        category = categories[selectedIndex]
        
        // 데이터 로딩 완료 후 착용 중 아이템 선택
        callGetItems { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                // 먼저 모든 선택 해제
                for indexPath in self.itemListModalView.itemCollectionView.indexPathsForSelectedItems ?? [] {
                    self.itemListModalView.itemCollectionView.deselectItem(at: indexPath, animated: false)
                }
                
                if let delegate = self.itemDelegate as? GroViewController {
                    let equippedNames = delegate.categoryToEquippedName
                    
                    let items: [ItemList]
                    if isMyItems {
                        items = myItems
                    } else {
                        items = shopItems
                    }
                    
                    // 착용 중 아이템이랑 로딩 된 아이템 이름으로 비교
                    for (index, item) in items.enumerated() {
                        if equippedNames[item.category] == item.name {
                            let indexPath = IndexPath(item: index, section: 0)
                            self.itemListModalView.itemCollectionView.selectItem(
                                at: indexPath,
                                animated: false,
                                scrollPosition: []
                            )
                        }
                    }
                }
            }
        }
        
        UIView.transition(
            with: itemListModalView.itemCollectionView,
            duration: 0.1,
            options: [.transitionCrossDissolve],
            animations: {
                self.currentSegmentIndex = selectedIndex
            },
            completion: nil
        )
    }
    
    @objc
    private func didTapPurchaseButton() {
        guard let item = selectedItem else { return }
        
        let isShortage = item.price > currentCredit
        let purchaseModalVC = PurchaseModalViewController(
            isShortage: isShortage,
            credit: item.price,
            itemId: item.id,
            category: item.category
        )
        
        purchaseModalVC.modalPresentationStyle = .pageSheet
        presentSheet(purchaseModalVC, heightRatio: 0.36)
        let inset: CGFloat = 100
        itemListModalView.updateCollectionViewConstraints(forSuperviewInset: inset)
    }
}



//MARK: - Extension
//MARK: UICollectionView DataSource
extension ItemListModalViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isMyItems ? myItems.count : shopItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isMyItems {
            // 마이 아이템 셀
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MyItemCollectionViewCell.identifier,
                for: indexPath
            ) as? MyItemCollectionViewCell else { return UICollectionViewCell() }
            
            let item = myItems[indexPath.row]
            
            // 착용 여부 계산
            var isEquipped = false
            if let delegate = itemDelegate as? GroViewController {
                let equippedNames = delegate.categoryToEquippedName
                isEquipped = equippedNames[item.category] == item.name
            }
            
            // 셀 UI 세팅
            cell.configure(item: item, isEquipped: isEquipped)
            
            // 착용 중 아이템은 선택 상태로 표시
            if isEquipped {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
            
            return cell
            
        } else {
            // 아이템샵 셀
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ItemCollectionViewCell.identifier,
                for: indexPath
            ) as? ItemCollectionViewCell else { return UICollectionViewCell() }
            
            let item = shopItems[indexPath.row]
            
            // 착용 여부 계산
            var isEquipped = false
            if let delegate = itemDelegate as? GroViewController {
                let equippedNames = delegate.categoryToEquippedName
                isEquipped = equippedNames[item.category] == item.name
            }
            
            // 셀 UI 세팅
            cell.configure(item: item, isEquipped: isEquipped)
            
            // 착용 중 아이템은 선택 상태로 표시
            if isEquipped {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
            
            return cell
        }
    }

}

//MARK: - UICollectionView Delegate
extension ItemListModalViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = isMyItems ? myItems[indexPath.row] : shopItems[indexPath.row]
        
        selectedItem = item
        itemListModalView.purchaseButton.updateCredit(item.price)
        itemDelegate?.didSelectItem(item.purchased, selectedItem: item)
        
        // 구매 여부에 따른 구매 버튼 상태
        itemListModalView.purchaseButton.isHidden = item.purchased
        let inset: CGFloat = item.purchased ? 100 : -16
        itemListModalView.updateCollectionViewConstraints(forSuperviewInset: inset)
    }

}

extension ItemListModalViewController: UICollectionViewDelegateFlowLayout {
    // 동적 셀 너비 조정
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let itemRow: CGFloat = 3
        let itemSpacing: CGFloat = 8
        let aspectRatio: CGFloat = 140 / 122
        
        let availableWidth = collectionView.bounds.width - (itemSpacing * 2)
        let itemWidth = floor(availableWidth / itemRow)
        let itemHeight = itemWidth * aspectRatio
        return CGSize(width: itemWidth, height: itemHeight)
    }
}