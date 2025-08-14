//
//  LoadingButton.swift
//  GrowIT
//
//  Created by 이수현 on 2/14/25.
//

import Foundation
import UIKit
import Lottie
import SnapKit

class LoadingButton: UIButton {
    
    let micImage = LottieAnimationView(name: "Loading").then {
        $0.loopMode = .loop
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = false
    }
    
    private let innerCircle = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 35
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        micImage.play()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        micImage.play()
    }
    
    private func setupUI() {
        addSubview(innerCircle)
        innerCircle.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
        
        innerCircle.addSubview(micImage)
        micImage.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.edges.equalToSuperview()
        }
    }
}
