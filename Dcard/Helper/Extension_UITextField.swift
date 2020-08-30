//
//  Extension_UINavigation.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/21.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

extension UITextField {
    func addTopBorder(lineWidth: CGFloat = 1, lineColor: UIColor = .gray) {
        let line = CALayer()
        line.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: lineWidth)
        line.backgroundColor = lineColor.cgColor
        self.layer.addSublayer(line)
    }
    func addBottomBorder(lineWidth: CGFloat = 1, lineColor: UIColor = .gray) {
        let line = CALayer()
        line.frame = CGRect(x: 0, y: self.frame.size.height - lineWidth, width: self.frame.size.width, height: lineWidth)
        line.backgroundColor = lineColor.cgColor
        self.layer.addSublayer(line)
    }
    func addleftBorder(lineWidth: CGFloat = 1, lineColor: UIColor = .gray) {
        let line = CALayer()
        line.frame = CGRect(x: 0, y: 0, width: lineWidth, height: self.frame.size.height)
        line.backgroundColor = lineColor.cgColor
        self.layer.addSublayer(line)
    }
    func addRightBorder(lineWidth: CGFloat = 1, lineColor: UIColor = .gray) {
        let line = CALayer()
        line.frame = CGRect(x: self.frame.size.width - lineWidth, y: 0, width: lineWidth, height: self.frame.size.height)
        line.backgroundColor = lineColor.cgColor
        self.layer.addSublayer(line)
    }
}
