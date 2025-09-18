//
//  VoiceDiaryTipCell.swift
//  GrowIT
//
//  Created by 허준호 on 9/18/25.
//

import UIKit

struct TipItem {
    let image: UIImage
    let content: String
}

class VoiceDiaryTipCell: UICollectionViewCell {
    static let identifier = "VoiceDiaryTipCell"
    
    private let box = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    private let label = UILabel().then {
        $0.font = .heading3SemiBold()
        $0.textColor = .gray100
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(box)
        
        box.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        box.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(260)
            $0.horizontalEdges.equalToSuperview()
        }
        
        box.addSubview(label)
        label.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with tip: TipItem) {
        imageView.image = tip.image
        label.text = tip.content
    }
}
