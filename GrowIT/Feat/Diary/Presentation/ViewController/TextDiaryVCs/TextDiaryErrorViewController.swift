//
//  ErrorViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/13/25.
//

import UIKit

class TextDiaryErrorViewController: UIViewController {
    
    weak var delegate: VoiceDiaryErrorDelegate?
    
    // MARK: - Properties
    let errorView = ErrorView()
    
    let diaryService = DiaryService()
    
    var diaryId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(errorView)
        errorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: Setup Actions
    private func setupActions() {
        errorView.exitButton.addTarget(self, action: #selector(mainVC), for: .touchUpInside)
        errorView.continueButton.addTarget(self, action: #selector(prevVC), for: .touchUpInside)
    }
    
    // MARK: @objc methods
    @objc func prevVC() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func mainVC() {
        callDeleteDiary()
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didTapExitButton()
        }
    }
    
    // MARK: Setup APIs
    private func callDeleteDiary() {
        diaryService.deleteDiary(
            diaryId: diaryId,
            completion: {[weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    print("Success: \(data)")
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
    }
}
