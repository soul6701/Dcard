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
        self.selectionStyle = .none
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.backgroundColor = highlighted ? #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 0.8842572774) : nil
    }
    func setContent(type: ProfileThreeCellType, name: String, image: UIImage, isNew: Bool) {
        self.lbTitle.text = name
        self.imageTitle.image = image
        self.viewNew.isHidden = !isNew
    }
}
