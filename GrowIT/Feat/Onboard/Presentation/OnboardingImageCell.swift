//
//  OnboardingImageCell.swift
//  GrowIT
//
//  Created by 허준호 on 2/6/25.
//

import UIKit
import Then
import SnapKit

class OnboardingImageCell: UICollectionViewCell {
    static let identifier: String = "OnboardingImageCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Property
    
    private lazy var imageView = UIImageView().then{
        $0.contentMode = .scaleAspectFill
    }
    
    // MARK: - constraints()
    
    private func constraints() {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    public func figure(index: Int){
        self.imageView.image = UIImage(named: "onboarding\(index)")
    }
}
