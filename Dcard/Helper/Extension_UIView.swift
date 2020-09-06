//
//  globalEnum.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/7/25.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    //設定subview的autolayout全部同parentView
    func setFixedView(_ view: UIView) {
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}
