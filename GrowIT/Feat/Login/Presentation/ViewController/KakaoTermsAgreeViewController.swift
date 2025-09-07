//
//  KakaoTermsAgreeViewController.swift
//  GrowIT
//
//  Created by 강희정 on 2/13/25.
//

import UIKit

class KakaoTermsAgreeViewController: UIViewController, UITableViewDelegate {
    
    // MARK: Properties
    let termsAgreeView = TermsAgreeView()
    let navigationBarManager = NavigationManager()
    let termsService = TermsService()
    
    var completionHandler: (([UserTermDTO]) -> Void)?
    var oauthUserInfo: OauthUserInfo
    
    // 약관 관련 데이터
    var termsList: [TermsData] = [] // 필수 약관
    var optionalTermsList: [TermsData] = [] // 선택 약관
    var agreedTerms: [Int: Bool] = [:] // termId 기준 동의 상태 저장
    var termsContentMap: [Int: String] = [:] // termId -> 약관 내용 저장 (약관 확인 뷰용)
    private var mandatoryTermIds: Set<Int> = [] // 필수 약관 ID 저장
    
    // MARK: - Initializer
    init(oauthUserInfo: OauthUserInfo) {
        self.oauthUserInfo = oauthUserInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegate()
        setupActions()
        callGetTerms()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        termsAgreeView.termsTableView.snp.updateConstraints {
            $0.height.equalTo(termsAgreeView.termsTableView.contentSize.height)
        }
        termsAgreeView.termsOptTableView.snp.updateConstraints {
            $0.height.equalTo(termsAgreeView.termsOptTableView.contentSize.height)
        }
    }
    
    // MARK: - SetupUI
    private func setupUI() {
        view.addSubview(termsAgreeView)
        termsAgreeView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.navigationController?.isNavigationBarHidden = false
        
        navigationBarManager.setTitle(
            to: self.navigationItem,
            title: "회원가입",
            textColor: .gray900,
            font: .heading1Bold()
        )
        
        navigationBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(prevVC)
        )
    }
    
    // MARK: - Setup Delegate
    private func setupDelegate() {
        termsAgreeView.termsTableView.tag = 0
        termsAgreeView.termsOptTableView.tag = 1
        
        termsAgreeView.termsTableView.dataSource = self
        termsAgreeView.termsTableView.delegate = self
        termsAgreeView.termsTableView.rowHeight = 60

        termsAgreeView.termsOptTableView.dataSource = self
        termsAgreeView.termsOptTableView.delegate = self
        termsAgreeView.termsOptTableView.rowHeight = 60

        // 셀을 등록 (코드로 생성하는 경우)
        termsAgreeView.termsTableView.register(TermsAgreeTableViewCell.self, forCellReuseIdentifier: TermsAgreeTableViewCell.identifier)
        termsAgreeView.termsOptTableView.register(TermsAgreeOptionalTableViewCell.self, forCellReuseIdentifier: TermsAgreeOptionalTableViewCell.identifier)
    }

    // MARK: - Setup Actions
    private func setupActions() {
        termsAgreeView.checkButton.addTarget(self, action: #selector(allCheck), for: .touchUpInside)
        termsAgreeView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - API 호출 (약관 목록 불러오기)
    private func callGetTerms() {
        termsService.getTerms { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let terms):
                    
                    // 필수 약관과 선택 약관으로 분리
                    self?.termsList = terms.filter { $0.type.uppercased() == "MANDATORY" }
                    self?.optionalTermsList = terms.filter { $0.type.uppercased() == "OPTIONAL" }
                    
                    // 필수 약관 ID 저장
                    self?.mandatoryTermIds = Set(self?.termsList.map { $0.termId } ?? [])
                    
                    // 약관 내용 저장 (약관 확인 뷰에서 사용)
                    self?.termsContentMap = terms.reduce(into: [:]) { $0[$1.termId] = $1.content }
                    
                    // 약관 동의 상태 초기화
                    self?.setupTermsView()
                    
                    // 테이블 뷰 업데이트
                    self?.termsAgreeView.termsTableView.reloadData()
                    self?.termsAgreeView.termsOptTableView.reloadData()
                    
                case .failure(let error):
                    print("약관 불러오기 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func setupTermsView() {
        // 필수 및 선택 약관 동의 상태 초기화
        for term in termsList + optionalTermsList {
            agreedTerms[term.termId] = false
        }
        
        print("약관 동의 상태 초기화: \(agreedTerms)")
    }
    
    private func validateAgreements() -> Bool {
        // mandatoryTermIds에 있는 모든 약관이 동의되었는지 확인
        return !mandatoryTermIds.contains { termId in
            agreedTerms[termId] == false
        }
    }

    // MARK: @objc methods
    @objc private func allCheck() {
        let isSelected = termsAgreeView.checkButton.isSelectedState()
        
        // 모든 필수 및 선택 약관을 `true` 또는 `false`로 설정
        for term in termsList + optionalTermsList {
            agreedTerms[term.termId] = isSelected
        }
        
        print("전체 동의 상태 업데이트: \(agreedTerms)")
        
        termsAgreeView.termsTableView.reloadData()
        termsAgreeView.termsOptTableView.reloadData()
        updateNextButtonState()
    }
    
    private func updateCheckButtonState() {
        let allTermsSelected = !termsList.contains { agreedTerms[$0.termId] == false }
        let allOptionalTermsSelected = !optionalTermsList.contains { agreedTerms[$0.termId] == false }
        
        let allSelected = allTermsSelected && allOptionalTermsSelected
        termsAgreeView.checkButton.isEnabledState = allSelected
        termsAgreeView.checkButton.updateButtonColor()
        
        updateNextButtonState()
    }

    private func updateNextButtonState() {
        let allTermsSelected = !termsList.contains { agreedTerms[$0.termId] == false }
        
        termsAgreeView.nextButton.setButtonState(
            isEnabled: allTermsSelected,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400
        )
    }
    
    @objc private func nextButtonTapped() {
        guard validateAgreements() else {
            print("필수 약관을 모두 동의해야 함.")
            return
        }

        let agreedList = (termsList + optionalTermsList).map { term in
            UserTermDTO(termId: term.termId, agreed: agreedTerms[term.termId] ?? false)
        }
        completionHandler?(agreedList)
    }
    
    @objc private func prevVC() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension KakaoTermsAgreeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 { // 필수 약관 테이블
            return termsList.count
        } else if tableView.tag == 1 { // 선택 약관 테이블
            return optionalTermsList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 { // 필수 약관
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TermsAgreeTableViewCell.identifier, for: indexPath) as? TermsAgreeTableViewCell else {
                return UITableViewCell()
            }
            
            let term = termsList[indexPath.row]
            let numberedTitle: String
            if term.termId == 7 {
                numberedTitle = "서비스 이용약관"
            } else {
                numberedTitle = "개인정보 수집•이용 동의"
            }
            
            // 화살표 버튼을 눌렀을 때 상세 화면으로 이동
            cell.detailButton.addTarget(self, action: #selector(showTermsDetail(_:)), for: .touchUpInside)
            cell.detailButton.tag = term.termId
            cell.detailButton.accessibilityLabel = numberedTitle
            
            cell.configure(
                title: numberedTitle,
                content: term.content,
                isAgreed: agreedTerms[term.termId] ?? false
            )
            
            // 약관 동의 버튼 클릭 이벤트 처리
            cell.onAgreeButtonTapped = { [weak self] in
                guard let self = self else { return }
                self.agreedTerms[term.termId] = !(self.agreedTerms[term.termId] ?? false)
                print("업데이트된 약관 동의 상태: \(self.agreedTerms)")
                
                self.updateCheckButtonState()
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            
            return cell
        } else { // 선택 약관
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TermsAgreeOptionalTableViewCell.identifier, for: indexPath) as? TermsAgreeOptionalTableViewCell else {
                return UITableViewCell()
            }
            
            let term = optionalTermsList[indexPath.row]
            cell.configure(
                title: term.title,
                content: term.content,
                isAgreed: agreedTerms[term.termId] ?? false
            )
            
            // 약관 동의 버튼 클릭 이벤트 처리
            cell.onAgreeButtonTapped = { [weak self] in
                guard let self = self else { return }
                self.agreedTerms[term.termId] = !(self.agreedTerms[term.termId] ?? false)
                print("업데이트된 약관 동의 상태: \(self.agreedTerms)")
                
                self.updateCheckButtonState()
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            
            return cell
        }
    }
    
    @objc private func showTermsDetail(_ sender: UIButton) {
        let termId = sender.tag
        let title = sender.accessibilityLabel ?? "약관 상세"

        guard let term = (termsList + optionalTermsList).first(where: { $0.termId == termId }) else { return }

        let detailVC = TermsDetailViewController(navigationBarTitle: title)
        detailVC.termsContent = term.content
        detailVC.termId = term.termId
        
        detailVC.onAgreeCompletion = { [weak self] agreedTermId in
            guard let self = self else { return }
            self.agreedTerms[agreedTermId] = true
            
            self.termsAgreeView.termsTableView.reloadData()
            self.termsAgreeView.termsOptTableView.reloadData()
            
            // 👉 여기서 버튼 상태 갱신 추가
            self.updateCheckButtonState()
        }

        navigationController?.pushViewController(detailVC, animated: true)
    }
}
