//
//  Constants.swift
//  GrowIT
//
//  Created by 이수현 on 1/19/25.
//

import Foundation
import UIKit

struct Constants {

    public struct API {
        static let baseURL = "http://43.200.242.14:8080"
        static let diaryURL = "\(baseURL)/diaries"

        static let GroURL = baseURL + "/characters"
        static let itemURL = baseURL + "/items"
        static let imageURL = baseURL + "/"

        static let authURL = "\(baseURL)/auth"
        static let userURL = "\(baseURL)/users"
        static let withdrawalURL = "\(baseURL)/withdrawal"
        static let challengeURL = "\(baseURL)/challenges"
        static let s3URL = "\(baseURL)/s3"
    }
    
    public struct Screen {
        static let ScreenWidth = UIScreen.main.bounds.width
        static let ScreenHeight = UIScreen.main.bounds.height
        static let CalenderRatio = 366.0 / 932.0
    }
}
