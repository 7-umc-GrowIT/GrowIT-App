//
//  ChallengeToast.swift
//  GrowIT
//
//  Created by 허준호 on 2/13/25.
//

import UIKit
import SnapKit

class CustomToast {
    private var containerWidth: CGFloat
    private var containerHeight: CGFloat
    private var imageWidthHeight: CGFloat
    private var spaceBetweenImageAndLabel: CGFloat

    init(containerWidth: CGFloat = 210, containerHeight: CGFloat = 56, imageWidthHeight: CGFloat = 24, spaceBetweenImageAndLabel: CGFloat = 8) {
        self.containerWidth = containerWidth
        self.containerHeight = containerHeight
        self.imageWidthHeight = imageWidthHeight
        self.spaceBetweenImageAndLabel = spaceBetweenImageAndLabel

            }

    func show(image: UIImage, message: String, font: UIFont) {
        guard let keyWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else {
            print("Toast Error: No key window available")
            return
        }

        let containerView = UIView().then {
            $0.backgroundColor = UIColor(hex: "#00000066")
            $0.layer.cornerRadius = 16
        }

        let imageView = UIImageView().then {
            $0.image = image
            $0.contentMode = .scaleAspectFit
        }

        let label = UILabel().then {
            $0.text = message
            $0.font = font
            $0.textColor = .white
            $0.textAlignment = .center
            $0.numberOfLines = 1
        }


        keyWindow.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-136)
            make.width.equalTo(containerWidth)
            make.height.equalTo(containerHeight)
        }

        containerView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(imageWidthHeight)
        }

        containerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.leading.equalTo(imageView.snp.trailing).offset(spaceBetweenImageAndLabel)
        }

        // 토스트 페이드 인, 딜레이 후 페이드 아웃
        containerView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            containerView.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                UIView.animate(withDuration: 0.5, animations: {
                    containerView.alpha = 0
                }) { _ in
                    containerView.removeFromSuperview()
                }
            }
        }
    }
}

