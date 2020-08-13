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
}
enum strokeColorType: Int {
    case red = 0
    case green = 1
    case blue = 2
}
class SkitchVC: UIViewController {

    
    @IBOutlet var slideColor: [UISlider]!
    @IBOutlet weak var btnSetColor: UIButton!
    @IBOutlet var txtColor: [UITextField]!
    @IBOutlet weak var viewColor: UIView!
    @IBOutlet weak var viewCanvas: UIView!
    @IBOutlet weak var viewEraser: UIImageView!
    var linePrintColor: UIColor = .systemBlue
    var lineClearColor: UIColor = .black
    var lineWidth: CGFloat = 10
    var path: UIBezierPath!
    var startPoint: CGPoint!
    var touchPoint: CGPoint!
    var mode: SkitchMode = .print
    var show = false
    var currentTxt: UITextField?
    var (red, green, blue) = (127.5, 127.5, 127.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.startPoint = touches.first?.location(in: self.viewCanvas)
        if mode != .print {
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
        draw()
        self.startPoint = self.touchPoint
    }
    @IBAction func onClickSetColor(_ sender: UIButton) {
        self.show = !self.show
        self.viewColor.isHidden = !self.show
        if !self.show, let txt = self.currentTxt {
            txt.resignFirstResponder()
            self.currentTxt = nil
        }
    }
    @IBAction func updateColorValueBySlider(_ sender: UISlider) {
        if let index = self.slideColor.firstIndex(of: sender) {
            self.txtColor[index].text = "\((Int)(sender.value))"
        }
    }
    @IBAction func updateColorValueByTxtField(_ sender: UITextField) {
        sender.becomeFirstResponder()
        self.currentTxt = sender
    }
}

extension SkitchVC {
    private func initView() {
        
        self.viewColor.isHidden = true
        self.txtColor.forEach { (txt) in
            txt.delegate = self
        }
        self.slideColor.forEach { (slider) in
            slider.value = 127.5
        }
        self.btnSetColor.backgroundColor = UIColor(red: CGFloat(self.slideColor[0].value), green: CGFloat(self.slideColor[1].value), blue: CGFloat(self.slideColor[2].value), alpha: 1)
        
        //橡皮擦手勢設定
        let gesClear = UITapGestureRecognizer(target: self, action: #selector(clear(_:)))
        gesClear.numberOfTapsRequired = 1
        let gesPrint = UITapGestureRecognizer(target: self, action: #selector(print(_:)))
        gesPrint.numberOfTapsRequired = 2
        gesClear.require(toFail: gesPrint)
        self.viewEraser.addGestureRecognizer(gesClear)
        self.viewEraser.addGestureRecognizer(gesPrint)
    }
    private func draw() {
        let layer = CAShapeLayer()
        layer.path = self.path.cgPath
        layer.strokeColor = mode != .clear ? self.linePrintColor.cgColor : self.lineClearColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = self.lineWidth
        self.viewCanvas.layer.addSublayer(layer)
        self.view.setNeedsLayout()
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
            DispatchQueue.main.async {
                self.btnSetColor.backgroundColor = UIColor(red: CGFloat(self.slideColor[0].value), green: CGFloat(self.slideColor[1].value), blue: CGFloat(self.slideColor[2].value), alpha: 1)
            }
        }
    }
}
