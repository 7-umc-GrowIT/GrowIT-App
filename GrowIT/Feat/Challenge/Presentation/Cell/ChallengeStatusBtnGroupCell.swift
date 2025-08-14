//
//  ChallengeStatusBtnGroupCell.swift
//  GrowIT
//
//  Created by 허준호 on 1/24/25.
//

import UIKit
import Then
import SnapKit

class ChallengeStatusBtnGroupCell: UICollectionViewCell {
    static let identifier: String = "ChallengeStatusBtnGroupCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        addComponent()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Property
    private lazy var button = UIView().then{
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 6
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
    }
    
    private lazy var title = UILabel().then{
        $0.text = "완료"
        $0.textColor = .gray300
        $0.font = .heading3SemiBold()
    }
    
    // MARK: - addFunction & Constraints
    
    private func addComponent(){
        self.addSubview(button)
        button.addSubview(title)
    }
    
    private func constraints(){
        
        button.snp.makeConstraints{
            $0.edges.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        title.snp.makeConstraints{
            $0.center.equalToSuperview()
        }
    }
    
    public func figure(titleText:String, isClicked: Bool){
        self.title.text = titleText
        //self.title.sizeToFit()
//        
//        let buttonPadding: CGFloat = 32
//        button.snp.updateConstraints {
//            $0.width.equalTo(self.title.frame.width + 32)
//        }
        
        if(isClicked){
            self.title.textColor = .primary700
            self.title.font = .heading3Bold()
            self.button.backgroundColor = .primary100
        }else{
            self.title.textColor = .gray300
            self.button.backgroundColor = .white
            self.button.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        }
    }
    
}
