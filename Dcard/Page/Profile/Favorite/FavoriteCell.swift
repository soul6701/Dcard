//
//  FavoriteCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/14.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class FavoriteCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func setContent(name: String, imageString: String) {
        self.lbTitle.text = name
        self.imageView.kf.setImage(with: URL(string: imageString))
    }
}
