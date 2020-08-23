//
//  CatalogVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/7/10.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class CatalogVC: UIViewController {
    var myScrollView: UIScrollView!
    var fullSize :CGSize!
    let viewTab = UIView(frame: CGRect(x: 0, y: 60, width: 50, height: 5))
    var current = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
    }
}
