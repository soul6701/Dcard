//
//  Extension_Color.swift
//  Dcard
//
//  Created by mason on 2020/12/10.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import Foundation

extension UIColor {
    public static func randomColor() -> UIColor {
        return UIColor(red: CGFloat((0...255).randomElement()!) / 255, green: CGFloat((0...255).randomElement()!) / 255, blue: CGFloat((0...255).randomElement()!) / 255, alpha: 1)
    }
}
