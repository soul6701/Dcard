//
//  NotifyVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/7/10.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class NotifyVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        let image = UIImage.gif(name: "柴犬")
        let imageView = UIImageView(image: image)
        imageView.frame = view.frame
        view.addSubview(imageView)
    }
}
