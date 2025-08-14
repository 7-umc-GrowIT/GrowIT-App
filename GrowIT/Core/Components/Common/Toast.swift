import UIKit

class Toast {
    static func show(image: UIImage, message: String, font: UIFont) {
        
        guard let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else {
            print("Toast Error: No key window available")
            return
        }
        
        let containerView = UIView().then {
            $0.backgroundColor = UIColor(hex: "#00000066")
            $0.layer.cornerRadius = 16
        }
        
        let imageView = UIImageView().then {
            $0.image = image
            $0.backgroundColor = .clear
            $0.contentMode = .scaleAspectFit
        }
        
        let label = UILabel().then {
            $0.text = message
            $0.font = .heading3SemiBold()
            $0.textColor = .white
            $0.textAlignment = .center
        }
        
        keyWindow.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-136)
            make.width.equalTo(320)
            make.height.equalTo(56)
        }
        
        containerView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(20)
            make.width.height.equalTo(24)
        }
        
        containerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(6)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalTo(imageView.snp.top).offset(1)
            make.centerY.equalTo(imageView.snp.centerY)
        }
        
        
        containerView.alpha = 0.0
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            containerView.alpha = 1.0
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                    containerView.alpha = 0.0
                }) { _ in
                    containerView.removeFromSuperview()
                }
            }
        }
    }
}
