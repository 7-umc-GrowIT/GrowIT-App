//
//  PurchaseModalViewController.swift
//  GrowIT
//
//  Created by 오현민 on 1/12/25.
//

import UIKit

class PurchaseModalViewController: UIViewController {
    // MARK: Properties
    let itemService = ItemService()
    
    private let isShortage: Bool
    private let credit: Int
    private let itemId: Int
    
    //MARK: -Views
    private lazy var purchaseModalView = PurchaseModalView().then {
        $0.cancleButton.addTarget(self, action: #selector(didTapCancleButton), for: .touchUpInside)
        $0.purchaseButton.addTarget(self, action: #selector(didTapPurchaseButton), for: .touchUpInside)
        $0.purchaseButton.updateCredit(credit)
    }
    
    private lazy var shortageModalView = ShortageModalView().then {
        $0.confirmButton.addTarget(self, action: #selector(didTapCancleButton), for: .touchUpInside)
    }
    
    // MARK: - NetWork
    func callPostItemPurchase() {
        itemService.postItemPurchase(itemId: itemId, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                print("Success: \(data)")
                DispatchQueue.main.async {
                    self.setNotification()
                    self.handlePurchaseSuccess(itemId: self.itemId, category: "ITEM_CATEGORY")  // category는 서버 응답 기반으로 지정
                    self.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    //MARK: init
    init(isShortage: Bool, credit: Int, itemId: Int) {
        self.isShortage = isShortage
        self.credit = credit
        self.itemId = itemId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = isShortage ? shortageModalView : purchaseModalView
    }
    
    //MARK: Notification
    private func setNotification() {
        let Notification = NotificationCenter.default
        
        Notification.post(name: .creditUpdated, object: nil)
    }
    
    private func handlePurchaseSuccess(itemId: Int, category: String) {
        NotificationCenter.default.post(
            name: .purchaseCompleted,
            object: nil,
            userInfo: [
                "itemId": itemId,
                "category": category
            ]
        )
    }
    
    //MARK: event
    @objc
    private func didTapCancleButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func didTapPurchaseButton() {
        callPostItemPurchase()
    }
}
