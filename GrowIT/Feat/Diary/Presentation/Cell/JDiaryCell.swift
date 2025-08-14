//
//  JDiaryCell.swift
//  GrowIT
//
//  Created by 허준호 on 1/16/25.
//

import UIKit
import Then
import SnapKit

class JDiaryCell: UICollectionViewCell{
    
    static let identifier:String = "JDiaryCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addComponents()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var dateCell = UILabel().then{
        $0.text = "1"
        $0.font = .subBody1()
        $0.textColor = .grayColor900
    }
    
    private lazy var dateImage = UIImageView().then{
        $0.image = UIImage(named: "diaryIcon")
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    private func addComponents(){
        [dateCell, dateImage].forEach(self.addSubview)
    }
    
    private func constraints(){
        dateCell.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        dateImage.snp.makeConstraints{
            $0.top.equalTo(dateCell.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(16)
        }
    }
    
    public func figure(day:Int, isSunday:Bool, isFromCurrentMonth: Bool, isDark: Bool){
        dateCell.text = "\(day)"
        if(isSunday){
            dateCell.textColor = .negative400
        }else if(!isFromCurrentMonth){
            dateCell.textColor = .gray300
        }else{
            dateCell.textColor = isDark ? .white : .gray900
        }
        
        if(isDark){
            dateImage.image = UIImage(named: "diaryIcondark")
        }else{
            dateImage.image = UIImage(named: "diaryIcon")
        }
    }
    
    public func showIcon(isShow:Bool){
        dateImage.isHidden = !isShow
    }
}
