//
//  MyControllerPresentAsPopover.swift
//  GrowIT
//
//  Created by 이수현 on 1/27/25.
//

import UIKit
import Foundation

class MyControllerPresentAsPopover : NSObject, UIPopoverPresentationControllerDelegate {

    private static let sharedInstance = MyControllerPresentAsPopover()

    private override init() {
        super.init()
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    static func configurePresentation(forController controller : UIViewController) -> UIPopoverPresentationController {
        controller.modalPresentationStyle = .popover
        let presentationController = controller.presentationController as! UIPopoverPresentationController
        presentationController.delegate = MyControllerPresentAsPopover.sharedInstance
        return presentationController
    }
}
