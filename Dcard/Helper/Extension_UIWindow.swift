//
//  File.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/14.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

extension UIWindow {

    //取得第一響應者
    var firstResponder: UIResponder? {
        let firstResponderRef = perform(NSSelectorFromString("firstResponder"))
        return firstResponderRef?.takeRetainedValue() as? UIResponder
    }

}
