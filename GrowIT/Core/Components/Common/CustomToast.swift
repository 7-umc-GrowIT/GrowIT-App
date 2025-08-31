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
    
    // 현재 표시 중인 토스트 관리
    private static var currentToastContainer: UIView?
    
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

        // 기존 토스트가 있다면 즉시 제거
        CustomToast.currentToastContainer?.removeFromSuperview()
        CustomToast.currentToastContainer = nil

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

        // 현재 토스트로 설정
        CustomToast.currentToastContainer = containerView

        // 토스트 애니메이션
        containerView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            containerView.alpha = 1
        }) { _ in
            // 1초 후 사라지기 시작
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                // 현재 토스트가 이 토스트와 같을 때만 자동 제거
                if CustomToast.currentToastContainer == containerView {
                    UIView.animate(withDuration: 0.5, animations: {
                        containerView.alpha = 0
                    }) { _ in
                        containerView.removeFromSuperview()
                        // 현재 토스트 참조 정리
                        if CustomToast.currentToastContainer == containerView {
                            CustomToast.currentToastContainer = nil
                        }
                    }
                }
            }
        }
    }
}
