//
//  File.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/14.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

extension UIPickerView {
    func setBackgroundImage(_ image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.frame = self.frame
        self.insertSubview(imageView, at: 0)
    }
}
