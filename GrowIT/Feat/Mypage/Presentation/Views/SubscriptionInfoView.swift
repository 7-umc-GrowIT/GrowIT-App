//
//  SubscriptionInfoView.swift
//  GrowIT
//
//  Created by 오현민 on 7/27/25.
//

import UIKit

class SubscriptionInfoView: UIView {
    // MARK: - Properties
    private var isSubscribed: Bool = true
    private var tableViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Components
    private lazy var titleLabel = UILabel().then {
        $0.text = "현재 그로우잇 멤버십\n 구독 중이에요"
        $0.font = UIFont.heading2Bold()
        $0.textColor = UIColor.grayColor900
        $0.asColor(targetString: "구독 중", color: UIColor.primary400)
        $0.textAlignment = .center
    }

    private lazy var subLabel = AppLabel(
        text: "다음 결제 예정일은 2025년 4월 1일입니다",
        font: .body2SemiBold(),
        textColor: .gray500
    )

    private lazy var boxImage = UIImageView().then {
        $0.image = UIImage(named: "GrowIT_Box")
        $0.contentMode = .scaleAspectFill
    }

    public lazy var subscriptionInfoTableView = UITableView(frame: .zero, style: .grouped).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = false
    }

    private lazy var subscriptionPeriod = GrayBoxView(
        grayText: "멤버십 기간",
        blackText: "2025년 3월 31일까지"
    )

    private lazy var cancleSubscription = SmallTextButton(title: "정기 구독 해지")
    private lazy var subscriptionButton = GradientButton2()

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setView()
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - SetUI
    private func setView() {
        addSubviews([
            titleLabel,
            subLabel,
            boxImage,
            subscriptionPeriod,
            subscriptionInfoTableView,
            cancleSubscription,
            subscriptionButton
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tableViewHeightConstraint?.constant = subscriptionInfoTableView.contentSize.height
    }

    private func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(48)
            $0.centerX.equalToSuperview()
        }

        subLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }

        boxImage.snp.makeConstraints {
            $0.top.equalTo(subLabel.snp.bottom).offset(44)
            $0.centerX.equalToSuperview()
        }

        subscriptionPeriod.snp.makeConstraints {
            $0.top.equalToSuperview().inset(48)
            $0.width.height.equalTo(430)
        }

        subscriptionInfoTableView.snp.makeConstraints {
            $0.top.equalTo(subscriptionPeriod.snp.bottom).offset(60)
            $0.horizontalEdges.equalToSuperview()
        }

        // 높이 제약 NSLayoutConstraint 따로 관리
        tableViewHeightConstraint = subscriptionInfoTableView.heightAnchor.constraint(equalToConstant: 100)
        tableViewHeightConstraint?.isActive = true

        cancleSubscription.snp.makeConstraints {
            $0.top.equalTo(subscriptionInfoTableView.snp.bottom).offset(53)
            $0.leading.equalToSuperview().inset(24)
        }
    }

    // MARK: - Functional
    func updateSubscriptionUI(isSubscribed: Bool) {
        self.isSubscribed = isSubscribed

        if isSubscribed {
            applySubscribedUI()
        } else {
            applyUnsubscribedUI()
        }
        layoutIfNeeded()
    }

    private func applySubscribedUI() {
        titleLabel.text = "현재 그로우잇 멤버십\n 구독 중이에요"
        titleLabel.asColor(targetString: "구독 중", color: UIColor.primary400)
        subLabel.text = "다음 결제 예정일은 2025년 4월 1일입니다"

        subscriptionPeriod.isHidden = false
        cancleSubscription.isHidden = false
        subscriptionButton.isHidden = true
    }

    private func applyUnsubscribedUI() {
        titleLabel.text = "아직 그로우잇 멤버십을\n구독하지 않으셨나요?"
        titleLabel.asColor(targetString: "구독하지 않으셨나요?", color: UIColor.primary400)
        subLabel.text = "멤버십을 구독하고 자유롭게 그로를 꾸며 보세요!"

        subscriptionPeriod.isHidden = true
        cancleSubscription.isHidden = true
        subscriptionButton.isHidden = false

        if subscriptionButton.superview == nil {
            addSubview(subscriptionButton)
        }
        subscriptionButton.snp.remakeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
        }
    }
}
