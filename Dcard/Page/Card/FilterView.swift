//
//  FilterView.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/6.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import SwiftMessages

protocol FilterViewDelegate {
    func select(cardMode: CardMode)
}
class FilterView: MessageView {


    @IBOutlet var btnSex: [UIButton]!
    
    private var delegate: FilterViewDelegate?
    
    override func awakeFromNib() {
        self.btnSex.forEach { (btn) in
            btn.layer.cornerRadius = 12
        }
    }
    func setDelegate(delegate: FilterViewDelegate) {
        self.delegate = delegate
    }
    @IBAction func didClickBtnSex(_ sender: UIButton) {
        self.delegate?.select(cardMode: CardMode(rawValue: sender.tag) ?? CardMode.all)
    }
}
