//
//  Constant.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/7/11.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class Size {
    static let screenHeight = UIScreen.main.bounds.height
    static let screenWidth = UIScreen.main.bounds.width
    static var bottomSpace: CGFloat {
        return self.screenHeight / 12
    }
}
