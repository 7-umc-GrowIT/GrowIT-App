//
//  GroViewController.swift
//  GrowIT
//
//  Created by 오현민 on 1/8/25.
//

import UIKit
import SnapKit

class GroViewController: UIViewController, ItemListDelegate {
    // MARK: - Properties
    let userService = UserService()
    let groService = GroService()
    let itemService = ItemService()
    private lazy var itemListModalVC = ItemListModalViewController()
    private lazy var currentCredit: Int = 0
    
    private var itemListBottomConstraint: Constraint?
    private var selectedItem: ItemList?
    var originalEquippedItem: [String: Int] = [:]
    var categoryToEquippedId: [String: Int] = [:]
    var categoryToEquippedName: [String: String] = [:]

    //MARK: - Views
    private lazy var groView = GroView().then {
        $0.zoomButton.addTarget(self, action: #selector(didTapZoomButton), for: .touchUpInside)
        $0.eraseButton.addTarget(self, action: #selector(didTapEraseButton), for: .touchUpInside)
        $0.purchaseButton.addTarget(self, action: #selector(didTapPurchaseButton), for: .touchUpInside)
    }
    
    private lazy var itemShopHeader = ItemShopHeader().then {
        $0.myItemButton.addTarget(self, action: #selector(didTapMyItemButton), for: .touchUpInside)
        $0.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = groView
        
        loadGroImage()
        setNotification()
        setView()
        setConstraints()
        setInitialState()
        callGetCredit()
        setDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    // MARK: - NetWork
    func callGetCredit() {
        userService.getUserCredits(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                currentCredit = data.currentCredit
                itemShopHeader.updateCredit(data.currentCredit)
                itemListModalVC.currentCredit = data.currentCredit
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    func callPatchItemState(itemId: Int, status: String) {
        itemService.patchItemState(itemId: itemId, data: ItemRequestDTO(status: status), completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success:
                GroImageCacheManager.shared.refreshGroImage { _ in
                    NotificationCenter.default.post(name: .groImageUpdated, object: nil)
                }
            case.failure(let error):
                print("Error: \(error)")
            }
        })
    }
    
    //MARK: - Delegate Method
    func didSelectItem(_ isPurchased: Bool, selectedItem: ItemList?) {
        groView.purchaseButton.isHidden = isPurchased
        guard let selectedItem = selectedItem else { return }
        
        let category = selectedItem.category
        let newItemId = selectedItem.id
        let currentItemId = categoryToEquippedId[category]
        
        if currentItemId == newItemId { return }
        
        // 구매하지 않은 경우 UI만 변경
        if !isPurchased {
            if let imageView = getImageViewForCategory(category) {
                imageView.kf.setImage(with: URL(string: selectedItem.groImageUrl), options: [.transition(.fade(0.3)), .cacheOriginalImage])
            }
            groView.purchaseButton.updateCredit(selectedItem.price)
            return
        }
        
        // 기존 착용 아이템 해제
        if let currentItemId = currentItemId {
            callPatchItemState(itemId: currentItemId, status: "UNEQUIPPED")
        }
        
        // 새로운 아이템 착용
        categoryToEquippedId[category] = newItemId
        categoryToEquippedName[category] = selectedItem.name
        callPatchItemState(itemId: newItemId, status: "EQUIPPED")
        
        if let imageView = getImageViewForCategory(category) {
            imageView.kf.setImage(with: URL(string: selectedItem.groImageUrl), options: [.transition(.fade(0.3)), .cacheOriginalImage])
        }
        
        itemListModalVC.itemListModalView.itemCollectionView.reloadData()  // ✅ UI 반영
    }
    
    private func setDelegate() {
        itemListModalVC.itemDelegate = self
    }
    
    private func getImageViewForCategory(_ category: String) -> UIImageView? {
        let categoryImageViews: [String: UIImageView] = [
            "BACKGROUND": groView.backgroundImageView,
            "OBJECT": groView.groObjectImageView,
            "PLANT": groView.groFlowerPotImageView,
            "HEAD_ACCESSORY": groView.groAccImageView
        ]
        return categoryImageViews[category]
    }
    
    //MARK: - Functional
    private func loadGroImage() {
        GroImageCacheManager.shared.fetchGroImage { [weak self] data in
            guard let self = self, let data = data else { return }
            self.updateCharacterView(with: data)
        }
    }
    
    private func updateCharacterView(with data: GroGetResponseDTO) {
        groView.groFaceImageView.kf.setImage(with: URL(string: data.gro.groImageUrl), options: [.transition(.fade(0.3)), .cacheOriginalImage])
        
        let categoryImageViews: [String: UIImageView] = [
            "BACKGROUND": groView.backgroundImageView,
            "OBJECT": groView.groObjectImageView,
            "PLANT": groView.groFlowerPotImageView,
            "HEAD_ACCESSORY": groView.groAccImageView
        ]
        
        categoryToEquippedId = data.equippedItems.reduce(into: [String: Int]()) { dict, item in
            dict[item.category] = item.id
        }
        categoryToEquippedName = data.equippedItems.reduce(into: [String: String]()) { dict, item in
            dict[item.category] = item.name
        }
        print("🔧 categoryToEquippedId 초기화: \(categoryToEquippedId)")
        print("🔧 categoryToEquippedName 초기화: \(categoryToEquippedName)")
        
        for item in data.equippedItems {
            if let imageView = categoryImageViews[item.category] {
                imageView.kf.setImage(with: URL(string: item.itemImageUrl), options: [.transition(.fade(0.3)), .cacheOriginalImage])
            }
        }
    }
    //MARK: Notification
    private func setNotification() {
        let Notification = NotificationCenter.default
        
        Notification.addObserver(self, selector: #selector(didCompletePurchase), name: .purchaseCompleted, object: nil)
        Notification.addObserver(self, selector: #selector(updateCredit), name: .creditUpdated, object: nil)
    }
    
    @objc
    func didCompletePurchase(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let itemId = userInfo["itemId"] as? Int,
              let category = userInfo["category"] as? String else {
            return
        }
        
        // 기존 착용 아이템 해제
        if let currentItemId = categoryToEquippedId[category] {
            callPatchItemState(itemId: currentItemId, status: "UNEQUIPPED")
        }
        
        // 새 아이템 착용
        categoryToEquippedId[category] = itemId
        callPatchItemState(itemId: itemId, status: "EQUIPPED")
        
        groView.purchaseButton.isHidden = true
        callGetCredit()
    }
    
    @objc
    func updateCredit() {
        callGetCredit()
    }
    
    //MARK: Event
    @objc
    private func didTapZoomButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        showModalView(isZoomedOut: sender.isSelected)
    }
    
    @objc
    private func didTapEraseButton() {
        let defaultFlowerPotId = 10
        let categoriesToClear = ["OBJECT", "HEAD_ACCESSORY", "PLANT"]
        
        categoriesToClear.forEach { category in
            if let itemId = categoryToEquippedId[category], itemId != defaultFlowerPotId {
                callPatchItemState(itemId: itemId, status: "UNEQUIPPED")
                categoryToEquippedId[category] = nil
            }
        }
        
        categoryToEquippedId["PLANT"] = defaultFlowerPotId
        callPatchItemState(itemId: defaultFlowerPotId, status: "EQUIPPED")
        
        groView.groAccImageView.image = nil
        groView.groObjectImageView.image = nil
        groView.groFlowerPotImageView.image = UIImage(named: "Gro_FlowerPot")
    }
    
    @objc
    private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func didTapMyItemButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        if sender.isSelected {
            groView.zoomButton.isSelected = false // 줌 버튼 상태 초기화
            showModalView(isZoomedOut: !sender.isSelected)
        }
        
        let imageName = sender.isSelected ?
        "GrowIT_MyItem_On" : "GrowIT_MyItem_Off"
        itemShopHeader.myItemButton.configuration?.image = UIImage(named: imageName)
        
        itemListModalVC.updateToMyItems(sender.isSelected)
        groView.purchaseButton.isHidden = true
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
        presentSheet(purchaseModalVC, heightRatio: 0.33)
    }
    
    //MARK: - UI 업데이트 함수
    private func showModalView(isZoomedOut: Bool) {
        updateItemListPosition(isZoomedOut: isZoomedOut)
        updateButtonStackViewPosition(isZoomedOut: isZoomedOut)
        updateZoomButtonImage(isZoomedOut: isZoomedOut)
        updateGroImageViewTopConstraint(isZoomedOut: isZoomedOut)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    private func updateItemListPosition(isZoomedOut: Bool) {
        let offset = isZoomedOut ? 500 : 0
        self.itemListBottomConstraint?.update(offset: offset)
    }
    
    private func updateButtonStackViewPosition(isZoomedOut: Bool) {
        groView.buttonStackView.snp.remakeConstraints {
            let bottomConstraint = isZoomedOut
            ? groView.purchaseButton.snp.top
            : itemListModalVC.view.snp.top
            $0.bottom.equalTo(bottomConstraint).offset(-24)
            $0.trailing.equalToSuperview().inset(24)
        }
    }
    
    private func updateZoomButtonImage(isZoomedOut: Bool) {
        let imageName = isZoomedOut ? "GrowIT_ZoomIn" : "GrowIT_ZoomOut"
        groView.zoomButton.configuration?.image = UIImage(named: imageName)
    }
    
    private func updateGroImageViewTopConstraint(isZoomedOut: Bool) {
        let inset = isZoomedOut ? 178 : 68
        groView.groImageViewTopConstraint?.update(inset: inset)
    }
    
    private func setInitialState() {
        groView.buttonStackView.snp.remakeConstraints {
            $0.bottom.equalTo( itemListModalVC.view.snp.top).offset(-24)
            $0.trailing.equalToSuperview().inset(24)
        }
    }
    //MARK: - 컴포넌트추가
    private func setView() {
        addChild(itemListModalVC)
        groView.addSubviews([itemShopHeader, itemListModalVC.view])
        itemListModalVC.didMove(toParent: self)
    }
    
    //MARK: - 레이아웃설정
    private func setConstraints() {
        itemShopHeader.snp.makeConstraints {
            $0.top.equalTo(groView.safeAreaLayoutGuide).inset(12)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }
        
        itemListModalVC.view.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.47)
            self.itemListBottomConstraint = $0.bottom.equalToSuperview().offset(0).constraint
        }
    }
}
