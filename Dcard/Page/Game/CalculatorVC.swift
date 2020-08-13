//
//  CalculatorVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/12.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import UIView_Shake

class CalculatorVC: UIViewController {
    @IBOutlet weak var lbResult: UILabel!
    @IBOutlet weak var lbRecord: UILabel!
    
    var num = ""
    var record = ""
    var formatter: NumberFormatter?
    var firstNum: Double?
    var secondNum: Double?
    var operation: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.formatter = NumberFormatter()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickNum(_ sender: UIButton) {
        self.num += "\(sender.tag)"
        self.record += "\(sender.tag)"
       
        let _num = self.formatter?.number(from: self.num) as! Double
        if self.operation == nil {
            self.firstNum = _num
            self.record = self.num
        } else {
            self.secondNum = _num
        }
        self.lbResult.text = self.num
        self.lbRecord.text = self.record
    }
    @IBAction func onClickClear(_ sender: UIButton) {
        self.num = ""
        self.record = ""
        self.operation = nil
        self.lbResult.text = "0"
        self.lbRecord.text = ""
    }
    @IBAction func onClickCal(_ sender: UIButton) {
        if let operation = self.operation, let n1 = self.firstNum, let n2 = self.secondNum {
            var temp = 0.0
            switch operation {
            case "+":
                temp = n1 + n2
            case "-":
                temp = n1 - n2
            case "x":
                temp = n1 * n2
            case "/":
                temp = n1 / n2
            default:
                break
            }
            self.firstNum = temp
            var str = "\(temp)"
            //若為整數移除小數點
            if floor(temp) == temp {
                str = "\((Int)(temp))"
            }
            //限制數字字數
            if str.count > 8 {
                str = String(str.prefix(8))
            }
            self.lbResult.text = str
        }
        self.num = ""
        if sender.titleLabel?.text != "=" {
            self.operation = sender.titleLabel?.text
            self.record += sender.titleLabel?.text ?? ""
        } else {
            self.view.shake(10, withDelta: 5)
            self.operation = nil
            self.record = "\(self.firstNum!)"
        }
        self.lbRecord.text = self.record
    }
}
