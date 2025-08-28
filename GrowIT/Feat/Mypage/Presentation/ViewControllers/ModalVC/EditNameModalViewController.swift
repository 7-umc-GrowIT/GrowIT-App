//
//  EditNameModalViewController.swift
//  GrowIT
//
//  Created by 오현민 on 7/12/25.
//

import UIKit

class EditNameModalViewController: UIViewController {
    // MARK: - Properties
    let groService = GroService()
    var isValidName: Bool = false
    var groName: String = ""
    var onNicknameChanged: ((String) -> Void)?
    
    //MARK: -Views
    private lazy var editnameModalView = EditNameModalView().then {
        $0.nickNameTextField.textField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        $0.changeButton.addTarget(self, action: #selector(didTapChangeButton), for: .touchUpInside)
    }
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = editnameModalView
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    // MARK: - NetWork
    func callPatchGroChangeNickname() {
        groService.patchGroChangeNickname(data: GroChangeNicknameRequestDTO(name: groName), completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success(let data):
                print("Success: \(data)")
                self.onNicknameChanged?(self.groName)
                //중복, 이전과동일닉네임
            case.failure(let error):
                print("Error: \(error)")
            }
        })
    }
    
    //MARK: - Functional
    //MARK: Event
    @objc
    func didTapChangeButton() {
        callPatchGroChangeNickname()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func textFieldsDidChange() {
        groName = editnameModalView.nickNameTextField.textField.text ?? ""
        isValidName = groName.count >= 2 && groName.count <= 8
        
        if !isValidName {
            editnameModalView.nickNameTextField.setError(message: "닉네임은 2~8자 이내로 작성해야 합니다")
        } else {
            editnameModalView.nickNameTextField.clearError()
        }
        updateNextButtonState()
    }
    
    private func updateNextButtonState() {
        editnameModalView.changeButton.isEnabled = isValidName
        
        editnameModalView.changeButton.setButtonState(
            isEnabled: isValidName,
            enabledColor: .black,
            disabledColor: .gray100,
            enabledTitleColor: .white,
            disabledTitleColor: .gray400)
    }
}
