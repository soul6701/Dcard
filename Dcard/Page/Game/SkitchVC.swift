//
//  SkitchVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/12.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

enum SkitchMode {
    case print
    case clear
    case setColor
    case setWidth
}
enum strokeColorType: Int {
    case red = 0
    case green = 1
    case blue = 2
}
class SkitchVC: UIViewController {

    
    @IBOutlet weak var lbRed: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet var rows: [UIStackView]!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet var slideColor: [UISlider]!
    @IBOutlet weak var btnSetColor: UIButton!
    @IBOutlet var txtColor: [UITextField]!
    @IBOutlet weak var viewColor: UIView!
    @IBOutlet weak var viewCanvas: UIView!
    @IBOutlet weak var viewEraser: UIImageView!
    var linePrintColor: UIColor!
    var lineClearColor: UIColor = .black
    var currentLineWidth: Float = 36
    var currentColorValue: [Float] = [127, 127, 127] //RGB
    var path: UIBezierPath!
    var startPoint: CGPoint!
    var touchPoint: CGPoint!
    var mode: SkitchMode = .print
    var show = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.startPoint = touches.first?.location(in: self.viewCanvas)
        if mode == .clear {
            viewEraser.center = self.startPoint
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchPoint = touches.first?.location(in: self.viewCanvas)
        self.path = UIBezierPath()
        self.path.move(to: self.startPoint)
        self.path.addLine(to: self.touchPoint)
        
        if mode == .clear {
            viewEraser.center = self.touchPoint
        }
        if mode == .print || mode == .clear {
            draw()
            self.startPoint = self.touchPoint
        }
    }
    @IBAction func onClickClear(_ sender: UIButton) {
        if let layers = self.viewCanvas.layer.sublayers {
            layers.forEach { (layer) in
                layer.removeFromSuperlayer()
            }
        }
    }
    @IBAction func updateColorValueBySlider(_ sender: UISlider) {
        if mode == .setColor {
            updateColor()
        }
        if mode == .setWidth {
            updateWidth()
        }
    }
    @IBAction func updateColorValueBytxtField(_ sender: UITextField) {
        sender.becomeFirstResponder()
    }
    @IBAction func onClickSetColor(_ sender: UIButton) {
        self.lbRed.isHidden = false
        self.slideColor[0].maximumValue = 255
        self.slideColor[0].minimumValue = 0
        self.lbTitle.text = "請選擇畫筆顏色"
        self.rows.forEach { (view) in
            view.isHidden = false
        }
        for i in 0..<3 {
            self.txtColor[i].text = "\((Int)(self.currentColorValue[i]))"
            self.slideColor[i].value = self.currentColorValue[i]
        }
        self.show = !self.show
        self.viewColor.isHidden = !self.show
        self.mode = self.show ? .setColor : .print
        if !self.show {
            self.txtColor.forEach { (txt) in
                txt.resignFirstResponder()
            }
        }
    }
    @IBAction func onClickSetWidth(_ sender: UIButton) {
        self.lbRed.isHidden = true
        self.slideColor[0].maximumValue = 72
        self.slideColor[0].minimumValue = 10
        self.lbTitle.text = "請選擇畫筆/橡皮擦粗細"
        self.txtColor[0].text = "\(Int(self.currentLineWidth))"
        self.slideColor[0].value = self.currentLineWidth
        self.rows.forEach { (view) in
            view.isHidden = true
        }
        self.show = !self.show
        self.viewColor.isHidden = !self.show
        self.mode = self.show ? .setWidth : .print
    }
}

extension SkitchVC {
    
    private func initView() {
        self.btnSetColor.layer.borderColor = UIColor.white.cgColor
        self.btnSetColor.layer.borderWidth = 3
        self.viewColor.layer.cornerRadius = 15
        self.viewColor.isHidden = true
        self.txtColor.forEach { (txt) in
            txt.delegate = self
        }
        updateColor()
        updateWidth()
        
        //橡皮擦手勢設定
        let gesClear = UITapGestureRecognizer(target: self, action: #selector(clear(_:)))
        gesClear.numberOfTapsRequired = 1
        let gesPrint = UITapGestureRecognizer(target: self, action: #selector(print(_:)))
        gesPrint.numberOfTapsRequired = 2
        gesClear.require(toFail: gesPrint)
        self.viewEraser.addGestureRecognizer(gesClear)
        self.viewEraser.addGestureRecognizer(gesPrint)
    }
    //繪製
    private func draw() {
        let layer = CAShapeLayer()
        layer.path = self.path.cgPath
        layer.strokeColor = mode != .clear ? self.linePrintColor.cgColor : self.lineClearColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = CGFloat(self.currentLineWidth)
        self.viewCanvas.layer.addSublayer(layer)
        self.viewCanvas.setNeedsLayout()
    }
    //更新顏色
    private func updateColor() {
        self.btnSetColor.backgroundColor = UIColor(red: CGFloat(self.slideColor[0].value) / 255, green: CGFloat(self.slideColor[1].value) / 255, blue: CGFloat(self.slideColor[2].value) / 255, alpha: 1)
        self.linePrintColor = self.btnSetColor.backgroundColor
        if mode == .setColor {
            for i in 0..<3 {
                self.txtColor[i].text = "\((Int)(self.slideColor[i].value))"
                self.currentColorValue[i] = self.slideColor[i].value
            }
        }
    }
    //更新粗細
    private func updateWidth() {
        self.height.constant = CGFloat(self.currentLineWidth)
        self.txtColor[0].text = "\((Int)(self.currentLineWidth))"
        if mode == .setWidth {
            self.currentLineWidth = self.slideColor[0].value
        }
    }
    @objc private func clear(_ ges: UITapGestureRecognizer) {
        mode = .clear
    }
    @objc private func print(_ ges: UITapGestureRecognizer) {
        mode = .print
    }
}
extension SkitchVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 3
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let index = self.txtColor.firstIndex(of: textField), let text = textField.text, let num = Float(text) {
            self.slideColor[index].value = num
            updateColor()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
