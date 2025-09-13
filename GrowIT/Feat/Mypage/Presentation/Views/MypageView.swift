//
//  MypageView.swift
//  GrowIT
//
//  Created by 오현민 on 6/9/25.
//

import UIKit

class MypageView: UIView {
    //MARK: - Components
    public lazy var profileView = UIView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
        $0.frame = CGRect(x: 0, y: 0, width: 108, height: 108)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 54
    }
    
    var backgroundImageView = UIImageView().then {
        $0.image = UIImage(named: "GrowIT_Background_Star") /// 그로 디폴트 이미지
        $0.contentMode = .scaleAspectFill
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    var groFaceImageView = UIImageView().then {
        $0.image = UIImage(named: "GrowIT_Gro") /// 그로 디폴트 이미지
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var groFlowerPotImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var groAccImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var groObjectImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public lazy var nicknameLabel = AppLabel(text: "",
                                         font: .heading2Bold(),
                                         textColor: .gray900)
    
    public lazy var editProfileButton = SmallTextButton(title: "프로필 수정하기",
                                                  titleColor: .gray500,
                                                  font: .subBody1())
    
    private lazy var subscrView = UIView().then {
        $0.addSubviews([subscribeButton, subscrTitleLabel, subscrDescLabel])
    }
    
    private lazy var subscrTitleLabel = AppLabel(text: "그로우잇 멤버십 구독하기",
                                              font: .bannerFont(),
                                              textColor: .gray900)
    
    private lazy var subscrDescLabel = AppLabel(text: "멤버십을 구독하고 자유롭게 그로를 꾸며 보세요!",
                                             font: .detail1Medium(),
                                             textColor: .primary600)
    
    public lazy var subscribeButton = UIButton().then {
        $0.setImage(UIImage(named: "GrowIt_Subscr"), for: .normal)
        $0.layer.cornerRadius = 24
    }
    
    public lazy var myPagetableView = UITableView(frame: .zero, style: .grouped).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = false
    }
    
    private lazy var copyrightLabel = AppLabel(text: "@ 2025 GrowIT All rights reserved.",
                                               font: .detail1Medium(),
                                               textColor: .gray400)
    
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - SetUI
    private func setView() {
        addSubviews([profileView, nicknameLabel, editProfileButton, subscrView, myPagetableView, copyrightLabel])
        
        profileView.addSubviews([
            backgroundImageView,
            groFlowerPotImageView,
            groFaceImageView,
            groAccImageView,
            groObjectImageView
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 테이블뷰의 contentSize에 맞게 높이 조정
        tableViewHeightConstraint?.constant = myPagetableView.contentSize.height
    }
    
    private func setConstraints() {
        profileView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).inset(32)
            $0.leading.equalToSuperview().inset(24)
            $0.width.height.equalTo(108)
        }
        
        [backgroundImageView, groFaceImageView, groFlowerPotImageView, groAccImageView, groObjectImageView].forEach {
            $0.snp.makeConstraints {
                // 그로 프로필용 확대
                $0.width.height.equalToSuperview().multipliedBy(1.65)
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview().offset(profileView.bounds.height * 0.12)
            }
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.top).offset(4)
            $0.leading.equalTo(profileView.snp.trailing).offset(24)
        }
        
        editProfileButton.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(profileView.snp.trailing).offset(24)
        }
        
        subscrView.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(112)
        }
        
        subscribeButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        subscrTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(17)
            $0.leading.equalToSuperview().inset(20)
        }
        
        subscrDescLabel.snp.makeConstraints {
            $0.top.equalTo(subscrTitleLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().inset(20)
        }
        
        myPagetableView.snp.makeConstraints {
            $0.top.equalTo(subscrView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }
        
        // 높이 제약은 NSLayoutConstraint로 따로 관리
        tableViewHeightConstraint = myPagetableView.heightAnchor.constraint(equalToConstant: 100)
        tableViewHeightConstraint?.isActive = true
        
        copyrightLabel.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(12)
            $0.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Development Helper
    func hideForDevelopment() {
        // 프로필 영역은 그대로 두고, 구독 뷰 이하를 가린다
        subscrView.isHidden = true
        myPagetableView.isHidden = true
    }
}
