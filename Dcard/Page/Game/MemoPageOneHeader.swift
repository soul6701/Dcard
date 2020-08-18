//
//  MemoPageOneHeader.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/17.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

protocol MemoPageOneHeaderDelegate {
    func addMember(name: String)
    func showSelection()
}
class MemoPageOneHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var lbTimes: UILabel!
    @IBOutlet weak var txtTimes: UITextField!
    @IBOutlet weak var txtName: UITextField!
    private var delegate: MemoPageOneHeaderDelegate?
    private var isFitness = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.txtTimes.isHidden = true
        self.lbTimes.isHidden = true
    }
    
    @IBAction func onClickAdd(_ sender: UIButton) {
        if self.isFitness {
            if let name = txtName.text, let times = self.txtTimes.text, !name.isEmpty && !times.isEmpty {
                let txt = name + " " + times + "組"
                self.delegate?.addMember(name: txt)
            }
        } else {
            if let name = txtName.text, name != "" {
                self.delegate?.addMember(name: name)
            }
        }
    }

    func setDelegate(_ delegate: MemoPageOneHeaderDelegate) {
        self.delegate = delegate
    }
    func setToFitness(item: String) {
        self.txtName.text = item
        self.isFitness = true
        self.txtTimes.isHidden = false
        self.lbTimes.isHidden = false
    }
    
    @IBAction func onClickTxtName(_ sender: UITextField) {
        if self.isFitness {
            self.delegate?.showSelection()
        }
    }
}
