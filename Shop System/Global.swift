//
//  Global.swift
//  Shop System
//
//  Created by Pavel Aristov on 03.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

class Global {
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    static var urlPath = "http://nk5.ru/"
    
    static var mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)

    static var sharedDefaults = UserDefaults(suiteName: "group.aristovz.TodayExtensionSharingDefaults")
    
    class var screenSize: CGSize {
        get {
            return UIScreen.main.bounds.size
        }
    }
    
    class var access_token: String? {
        get {
            return Global.sharedDefaults?.value(forKey: "access_token") as? String
        }
        set {
            Global.sharedDefaults?.set(newValue, forKey: "access_token")
        }
    }
    
    static var shortMonth: Dictionary<Int, String> = [1 : "Янв",
                                                      2 : "Февр",
                                                      3 : "Март",
                                                      4 : "Апр",
                                                      5 : "Май",
                                                      6 : "Июнь",
                                                      7 : "Июль",
                                                      8 : "Авг",
                                                      9 : "Сент",
                                                      10 : "Окт",
                                                      11 : "Нояб",
                                                      12 : "Дек"]
}

