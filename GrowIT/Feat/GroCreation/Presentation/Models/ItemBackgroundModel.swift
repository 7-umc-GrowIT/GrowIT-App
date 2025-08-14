//
//  ItemBackgroundModel.swift
//  GrowIT
//
//  Created by 오현민 on 1/31/25.
//

import Foundation

import Foundation
import UIKit

struct ItemBackgroundModel {
    var credit: Int
    var backgroundColor: UIColor
    var Item: UIImage
}

extension ItemBackgroundModel {
    static func dummy() -> [ItemBackgroundModel] {
        return [
            ItemBackgroundModel(credit: 0, backgroundColor: .itemYellow, Item: .itemBackgroundStar),
            ItemBackgroundModel(credit: 0, backgroundColor: .itemGreen, Item: .itemBackgroundTree),
            ItemBackgroundModel(credit: 0, backgroundColor: .itemPink, Item: .itemBackgroundHeart)
        ]
    }
}
