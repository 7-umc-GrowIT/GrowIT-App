//
//  DiaryAllViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/24/25.
//

import UIKit
import SnapKit

class DiaryAllViewController: UIViewController, UITableViewDelegate {
    
    // MARK: Properties
    private let diaryAllView = DiaryAllView()
    private let diaryService = DiaryService()
    let navigationBarManager = NavigationManager()
    
    private var diaries: [DiaryModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        setupDelegate()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callGetAllDiaries()
        setupNavigationBar()
        setupActions()
    
    }
    
    //MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        navigationBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(prevVC),
            tintColor: .black
        )
        
        navigationBarManager.setTitle(
            to: navigationItem,
            title: "나의 일기 기록",
            textColor: .gray900
        )
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadDiaries),
            name: .diaryReloadNotification,
            object: nil
        )
    }
    
    @objc private func reloadDiaries() {
        callGetAllDiaries()
    }
    
    private func setupCustomTitle() {
        // 기본 타이틀은 비우고
        self.title = ""
        
        // 커스텀 타이틀 뷰를 메인 뷰에 추가
        let titleContainer = UIView()
        titleContainer.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = "나의 일기 기록"
        titleLabel.font = UIFont.heading1Bold()
        titleLabel.textColor = UIColor.gray900
        titleLabel.textAlignment = .center
        
        diaryAllView.addSubview(titleContainer)
        titleContainer.addSubview(titleLabel)
        
        titleContainer.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            //$0.height.equalTo(44 + 31) // 기본 높이 + 패딩
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(15.5)
        }
        
        // 기존 뷰를 아래로 밀기
        diaryAllView.snp.remakeConstraints {
            $0.top.equalTo(titleContainer.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: Setup UI
    private func setupUI() {
        view.addSubview(diaryAllView)
        diaryAllView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: Setup Delegate
    private func setupDelegate() {
        diaryAllView.diaryTableView.dataSource = self
        diaryAllView.diaryTableView.delegate = self
    }
    
    // MARK: Setup Actions
    private func setupActions() {
        diaryAllView.onDateSelected = { [weak self] year, month in
            self?.callGetAllDiaries()
        }
    }
    
    
    // MARK: @objc Methods
    @objc func prevVC() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: Setup APIs
    private func callGetAllDiaries() {
        diaryService.fetchAllDiaries(
            year: diaryAllView.selectedYear,
            month: diaryAllView.selectedMonth,
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    print("Success")
                    guard let responseData = data else {
                        print("데이터가 nil")
                        return
                    }
                    
                    handleResponse(responseData)
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
    }
    
    private func handleResponse(_ data: DiaryGetAllResponseDTO) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.diaries = data.diaryList.map { diaryDTO in
                DiaryModel(diaryId: diaryDTO.diaryId, content: diaryDTO.content, date: diaryDTO.date)
            }
            
            self.diaryAllView.updateDiaryCount(data.listSize)
            
            self.diaryAllView.diaryTableView.reloadData()
        }
    }
    
}

extension DiaryAllViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        diaries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DiaryAllViewTableViewCell.identifier, for: indexPath) as? DiaryAllViewTableViewCell else {
            return UITableViewCell()
        }
        
        // Dummy 데이터로 셀 구성
        let diary = diaries[indexPath.row]
        cell.contentLabel.text = diary.content
        cell.dateLabel.text = diary.date
        cell.delegate = self
        return cell
    }
}

extension DiaryAllViewController: DiaryAllViewCellDelegate {
    func didTapButton(in cell: DiaryAllViewTableViewCell) {
        guard let indexPath = diaryAllView.diaryTableView.indexPath(for: cell) else { return }
        let diary = diaries[indexPath.row]
        
        let fixVC = DiaryPostFixViewController(
            text: diary.content,
            date: diary.date.formattedDate(),
            diaryId: diary.diaryId
        )
        
        fixVC.onDismiss = { [weak self] in
            self?.callGetAllDiaries()
        }
        
        let navController = UINavigationController(rootViewController: fixVC)
        
        presentSheet(navController, heightRatio: 0.65)
    }
}
