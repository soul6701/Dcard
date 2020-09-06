//
//  UserConfig.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/5.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation

public struct UserConfig {
    
    public var user: User = User()
    public var cardmode: Int = 0 // 0: All 1: male 2: female
}

enum CardMode: Int {
    case all = 0
    case male
    case female
    
    var stringValue: String {
        switch self {
        case .all:
            return "all"
        case .male:
            return "male"
        case .female:
            return "female"
        }
    }
}
