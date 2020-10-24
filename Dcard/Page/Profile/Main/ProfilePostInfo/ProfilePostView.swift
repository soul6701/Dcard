//
//  ProfilePostView.swift
//  Dcard
//
//  Created by 林英全 on 2020/10/24.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class ProfilePostView: UIView {

    @IBOutlet weak var imaveViewIcon: UIImageView!
    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbCreateTime: UILabel!
    
    private var user = ModelSingleton.shared.userConfig.user
    override func awakeFromNib() {
        self.layer.cornerRadius = 20
        self.imageViewAvatar.layer.cornerRadius = 30
        self.imageViewAvatar.kf.setImage(with: URL(string: self.user.avatar))
        self.lbName.text = self.user.lastName + self.user.firstName
        self.lbCreateTime.text = Date.getTimeIntervalSince(self.user.createAt)
    }
}
