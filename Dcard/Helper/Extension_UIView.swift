//
//  globalEnum.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/7/25.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

extension UIView {
    //設定subview的autolayout全部同parentView
    func setFixedView(_ view: UIView, inSafeArea: Bool = false) {
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { (maker) in
            if !inSafeArea {
                maker.bottom.top.leading.trailing.equalToSuperview()
            } else {
                maker.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
                maker.top.equalTo(self.safeAreaLayoutGuide.snp.top)
                maker.leading.equalTo(self.safeAreaLayoutGuide.snp.leading)
                maker.trailing.equalTo(self.safeAreaLayoutGuide.snp.trailing)
            }
        }
    }
    //動態更新View內容
    func fadeTransition(_ duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = .fade
        animation.duration = duration
        self.layer.add(animation, forKey: kCATransition)
    }
}
