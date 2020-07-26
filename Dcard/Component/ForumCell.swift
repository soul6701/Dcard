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
        // Initialization code
        logoImageView.layer.cornerRadius = 20
    }
    func setContent(logo: String, forum: String) {
        logoImageView.kf.setImage(with: URL(string: logo))
        lbforum.text = forum
    }
}
