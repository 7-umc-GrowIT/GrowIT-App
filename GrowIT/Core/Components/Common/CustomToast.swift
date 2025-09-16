//
//  ChallengeToast.swift
//  GrowIT
//
//  Created by 허준호 on 2/13/25.
//

import UIKit

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
        
        let stack = UIStackView().then {
            $0.spacing = spaceBetweenImageAndLabel
            $0.axis = .horizontal
            $0.alignment = .center // 🔥 중앙 정렬 추가
            $0.distribution = .fill // 🔥 분배 방식 명시
        }

        let imageView = UIImageView().then {
            $0.image = image
            $0.contentMode = .scaleAspectFit
        }

        let label = UILabel().then {
            $0.text = message
            $0.font = font
            $0.textColor = .white
            $0.textAlignment = .left
            $0.numberOfLines = 0
            $0.adjustsFontSizeToFitWidth = true
        }

        keyWindow.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-136)
            $0.width.equalTo(containerWidth)
            $0.height.equalTo(containerHeight)
        }
        
        stack.addArrangedSubViews([imageView, label])
        containerView.addSubview(stack)
        
        stack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.verticalEdges.equalToSuperview().inset(17)
        }
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(imageWidthHeight)
        }

        // 현재 토스트로 설정
        CustomToast.currentToastContainer = containerView

        // 토스트 애니메이션
        containerView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            containerView.alpha = 1
        }) { _ in
            // 1초 후 사라지기 시작
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
