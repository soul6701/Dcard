//
//  ProfileThreeTbCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/12.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class ProfileThreeTbCell: UITableViewCell {

    @IBOutlet var viewNew: customView!
    @IBOutlet var imageTitle: UIImageView!
    @IBOutlet var lbTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func setContent(type: ProfileThreeCellType, name: String, image: UIImage, isNew: Bool) {
        self.lbTitle.text = name
        self.imageTitle.image = image
        self.viewNew.isHidden = !isNew
    }
}
