//
//  ForumCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/7/25.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class ForumCell: UITableViewCell {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var lbforum: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.logoImageView.layer.cornerRadius = 20
    }
    func setContent(logo: String, forum: String) {
        self.logoImageView.kf.setImage(with: URL(string: logo))
        self.lbforum.text = forum
    }
}
