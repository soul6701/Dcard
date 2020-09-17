//
//  Extension_UINavigation.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/17.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import Foundation

extension UINavigationController {
    //設置過場完成行為
    func pushViewController(_ viewController: UIViewController,
                            animated: Bool,
                            completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}
