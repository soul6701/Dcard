//
//  MailAllCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/18.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import Kingfisher

class MailAllCell: UICollectionViewCell {

    @IBOutlet weak var imageAvatar: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbSchoolDepartment: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setContent(card: Card) {
        self.lbName.text = card.name
        self.lbSchoolDepartment.text = card.school + " " + card.department
        self.imageAvatar.kf.setImage(with: URL(string: card.photo))
    }
}
