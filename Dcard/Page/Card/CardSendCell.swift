//
//  CardSendCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/6.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

protocol CardSendCellDelegate {
    func didClickBtnSend()
}

class CardSendCell: UITableViewCell {

    @IBOutlet weak var btnSend: UIButton!
    private var delegate: CardSendCellDelegate?
    private var isFriend = false {
        didSet {
            if isFriend {
                self.btnSend.tintColor = .systemGray3
                self.btnSend.setTitle("已成為好友", for: .normal)
                self.btnSend.isEnabled = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    @IBAction func didClickBtnSend(_ sender: UIButton) {
        becomeFriend()
        self.delegate?.didClickBtnSend()
    }
    
    func setDelegate(delegate: CardSendCellDelegate) {
        self.delegate = delegate
    }
    func becomeFriend() {
        self.isFriend = true
    }
}
