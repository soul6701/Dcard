//
//  customView.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/9.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

@IBDesignable class customView: UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    @IBInspectable var viewBorderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var viewBorderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    @IBInspectable var gradientBGEnable: Bool = false {
        didSet {
            setGradientBG()
        }
    }
    @IBInspectable var leftColor: UIColor? = nil {
        didSet {
            setGradientBG()
        }
    }
    @IBInspectable var rightColor: UIColor? = nil {
        didSet {
            setGradientBG()
        }
    }
    private func setGradientBG() {
        guard gradientBGEnable, let leftColor = leftColor , let rightColor = rightColor else {
            return
        }
        let layer = CAGradientLayer()
        layer.frame = self.bounds
        layer.startPoint = CGPoint(x: 0.0, y: 0.0)
        layer.endPoint = CGPoint(x: 1.0, y: 0.0)
        layer.colors = [leftColor.cgColor , rightColor.cgColor]
        self.layer.insertSublayer(layer, at: 0)
    }
}

@IBDesignable class customButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var viewBorderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = viewBorderWidth
        }
    }
    
    @IBInspectable var viewBorderColor: UIColor? {
        didSet {
            layer.borderColor = viewBorderColor?.cgColor
        }
    }
    @IBInspectable var gradientBGEnable: Bool = false {
        didSet {
            setGradientBG()
        }
    }
    @IBInspectable var leftColor: UIColor? = nil {
        didSet {
            setGradientBG()
        }
    }
    @IBInspectable var rightColor: UIColor? = nil {
        didSet {
            setGradientBG()
        }
    }
    private func setGradientBG() {
        guard gradientBGEnable, let leftColor = leftColor , let rightColor = rightColor else {
            return
        }
        let layer = CAGradientLayer()
        layer.frame = self.bounds
        layer.startPoint = CGPoint(x: 0.0, y: 0.0)
        layer.endPoint = CGPoint(x: 1.0, y: 0.0)
        layer.colors = [leftColor.cgColor , rightColor.cgColor]
        self.titleLabel?.layer.insertSublayer(layer, at: 0)
    }
}
