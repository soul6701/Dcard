//
//  Extension_UIButton.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/17.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
extension UIButton {
    //title 加底線
    func underline() {
        guard let text = self.titleLabel?.text else { return }
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        
        self.setAttributedTitle(attributedString, for: .normal)
    }
}
