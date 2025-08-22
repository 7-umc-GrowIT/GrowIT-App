//
//  EditNameModalViewController.swift
//  GrowIT
//
//  Created by 오현민 on 7/12/25.
//

import UIKit

class EditNameModalViewController: UIViewController {
    //MARK: -Views
    private lazy var editnameModalView = EditNameModalView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = editnameModalView
    }

}
