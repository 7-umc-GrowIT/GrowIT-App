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
    private lazy var itemListModalView = ItemListModalView().then {
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
        let previousItemId = Set(self.shopItems.map { $0.id })
        
        itemService.getItemList(category: category) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.shopItems = data.itemList
                self.myItems = data.itemList.filter { $0.purchased }
                
                let newItemId = Set(self.shopItems.map { $0.id })
                if previousItemId != newItemId {
                    DispatchQueue.main.async {
                        self.itemListModalView.itemCollectionView.reloadData()
                        completion?()  // reloadData 완료 후 콜백 실행
                    }
                } else {
                    completion?() // 데이터 변화 없더라도 콜백 실행
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
        
        DispatchQueue.main.async {
            if isMyItems {
                // 먼저 모든 선택 해제
                for indexPath in self.itemListModalView.itemCollectionView.indexPathsForSelectedItems ?? [] {
                    self.itemListModalView.itemCollectionView.deselectItem(at: indexPath, animated: false)
                }
                
                // 착용 중인 아이템 선택
                print("🔍 마이 아이템 모드 - categoryToEquippedId: \(self.itemDelegate?.categoryToEquippedId ?? [:])")
                print("🔍 myItems count: \(self.myItems.count)")
                
                for (index, item) in self.myItems.enumerated() {
                    if let equippedItemId = self.itemDelegate?.categoryToEquippedId[item.category], equippedItemId == item.id {
                        print("✅ 착용 중 아이템 발견: \(item.name) (ID: \(item.id), Category: \(item.category))")
                        let indexPath = IndexPath(item: index, section: 0)
                        self.itemListModalView.itemCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                    }
                }
            } else {
                // 아이템샵 모드에서도 착용 중인 아이템 선택
                print("🔍 아이템샵 모드 - categoryToEquippedId: \(self.itemDelegate?.categoryToEquippedId ?? [:])")
                print("🔍 shopItems count: \(self.shopItems.count)")
                
                // 먼저 모든 선택 해제
                for indexPath in self.itemListModalView.itemCollectionView.indexPathsForSelectedItems ?? [] {
                    self.itemListModalView.itemCollectionView.deselectItem(at: indexPath, animated: false)
                }
                
                // 착용 중인 아이템 선택
                for (index, item) in self.shopItems.enumerated() {
                    if let equippedItemId = self.itemDelegate?.categoryToEquippedId[item.category], equippedItemId == item.id {
                        print("✅ 착용 중 아이템 발견: \(item.name) (ID: \(item.id), Category: \(item.category))")
                        let indexPath = IndexPath(item: index, section: 0)
                        self.itemListModalView.itemCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
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
    func didCompletePurchase() {
        itemListModalView.purchaseButton.isHidden = true
        callGetItems()
    }
    
    //MARK: Event
    @objc
    private func segmentChanged(_ segment: UISegmentedControl) {
        for index in 0..<segment.numberOfSegments {
            segment.setImage(
                defaultImages[index].withRenderingMode(.alwaysOriginal),
                forSegmentAt: index)
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
            
            DispatchQueue.main.async {
                // 먼저 모든 선택 해제
                for indexPath in self.itemListModalView.itemCollectionView.indexPathsForSelectedItems ?? [] {
                    self.itemListModalView.itemCollectionView.deselectItem(at: indexPath, animated: false)
                }
                
                // 현재 모드에 따라 착용 중인 아이템 선택
                if self.isMyItems {
                    // 마이 아이템 모드
                    for (index, item) in self.myItems.enumerated() {
                        if let equippedItemId = self.itemDelegate?.categoryToEquippedId[item.category],
                           equippedItemId == item.id {
                            let indexPath = IndexPath(item: index, section: 0)
                            self.itemListModalView.itemCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                        }
                    }
                } else {
                    // 아이템샵 모드
                    for (index, item) in self.shopItems.enumerated() {
                        if let equippedItemId = self.itemDelegate?.categoryToEquippedId[item.category],
                           equippedItemId == item.id {
                            let indexPath = IndexPath(item: index, section: 0)
                            self.itemListModalView.itemCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
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
            itemId: item.id
        )
        
        purchaseModalVC.modalPresentationStyle = .pageSheet
        if let sheet = purchaseModalVC.sheetPresentationController {
            //지원할 크기 지정
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .custom{ context in
                        0.32 * context.maximumDetentValue
                    }
                ]
            } else { sheet.detents = [.medium()] }
            sheet.prefersGrabberVisible = true
        }
        present(purchaseModalVC, animated: true, completion: nil)
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
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MyItemCollectionViewCell.identifier,
                for: indexPath) as? MyItemCollectionViewCell else
            { return UICollectionViewCell() }
            
            // 마이 아이템 셀 설정
            let item = myItems[indexPath.row]
            cell.isOwnedLabel.text = "보유 중"
            cell.itemImageView.kf.setImage(with: URL(string: item.imageUrl), options: [.transition(.fade(0.1)), .cacheOriginalImage])
            cell.updateSelectionState()
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ItemCollectionViewCell.identifier,
                for: indexPath) as? ItemCollectionViewCell else { return UICollectionViewCell() }
            
            // 아이템샵 셀 설정
            let item = shopItems[indexPath.row]
            if item.purchased {
                cell.creditStackView.isHidden = true
                cell.isOwnedLabel.isHidden = false
                cell.isOwnedLabel.text = "보유 중"
            } else {
                cell.creditStackView.isHidden = false
                cell.isOwnedLabel.isHidden = true
                cell.creditLabel.text = String(item.price)
            }
            cell.itemImageView.kf.setImage(
                with: URL(string: item.imageUrl),
                options: [.transition(.fade(0.1)), .cacheOriginalImage]
            )

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
        
        
        // 구매한 아이템의 경우
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
