//
//  MailCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/17.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import Kingfisher

class MailCell: UITableViewCell {
    
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var imageAvatar: UIImageView!
    @IBOutlet weak var viewCircle: customView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func setContent(mail: Mail) {
        let firstMessage = mail.message.first!
        self.viewCircle.backgroundColor = mail.isNew ? #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 0.8982769692) : .lightGray
        self.imageAvatar.kf.setImage(with: URL(string: mail.card.photo))
        self.lbName.text = mail.card.name
        self.lbMessage.text = firstMessage.text
        self.lbDate.text = firstMessage.date
    }
}
