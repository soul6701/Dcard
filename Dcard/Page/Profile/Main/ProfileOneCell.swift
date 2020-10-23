//
//  ProfileOneCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/12.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import Kingfisher

class ProfileOneCell: UITableViewCell {

    @IBOutlet var lbName: UILabel!
    @IBOutlet var lbSchool: UILabel!
    @IBOutlet var lbDepartment: UILabel!
    @IBOutlet var imageAvatar: UIImageView!
    
    override var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageAvatar.layer.cornerRadius = 65 / 2
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(toMyCard))
        self.imageAvatar.addGestureRecognizer(tap)
        self.selectionStyle = .none
    }
    
    func setContent(name: String, school: String, department: String, avatar: String) {
        self.lbName.text = name
        self.lbSchool.text = school
        self.lbDepartment.text = department
        self.imageAvatar.kf.setImage(with: URL(string: avatar))
    }
    @objc private func toMyCard() {
        ProfileManager.shared.toNextPage(next: .myCard)
    }
}
