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
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet var imageViews: [UIImageView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func setContent(name: String, imageStrings: [String]) {
        self.lbTitle.text = name
        if imageStrings.count > 1 {
           imageStrings.enumerated().forEach { (key, value) in
               self.imageViews[key].kf.setImage(with: URL(string: value))
            self.viewContainer.isHidden = false
            self.imageView.isHidden = true
           }
        } else {
            self.imageView.kf.setImage(with: URL(string: imageStrings.first ?? ""))
            self.viewContainer.isHidden = true
            self.imageView.isHidden = false
        }
    }
}
