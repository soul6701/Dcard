//
//  Extension_UIAlertAction.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/16.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import UIKit

///警告視窗屬性設置
extension UIAlertAction {
    var titleTextColor: UIColor? {
        get {
            return self.value(forKey: "titleTextColor") as? UIColor
        } set {
            self.setValue(newValue, forKey: "titleTextColor")
        }
    }
}
extension UIAlertController {
    func setMessageString(textSize: CGFloat, color: UIColor) {
        let message = NSMutableAttributedString(string: self.message!, attributes: [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: textSize)])
        self.setValue(message, forKey: "attributedMessage")
    }
    func setTitleString(textSize: CGFloat, color: UIColor) {
        let title = NSMutableAttributedString(string: self.title!, attributes: [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: textSize)])
        self.setValue(title, forKey: "attributedTitle")
    }
}
