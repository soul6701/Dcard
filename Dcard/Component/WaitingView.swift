//
//  WaitingView.swift
//  Dcard
//
//  Created by admin on 2020/10/19.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class WaitingView: UIView {
    private static var _shared: WaitingView?
    static var shared: WaitingView {
        if _shared == nil {
            _shared = UINib(nibName: "WaitingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? WaitingView
        }
        return _shared!
    }
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func show(_ willShow: Bool) {
        self.removeFromSuperview()
        self.loadingView.stopAnimating()
        
        if willShow {
            self.loadingView.startAnimating()
            let window = UIApplication.shared.windows.first!
            layer.zPosition = 6
            window.addSubview(self)
            self.translatesAutoresizingMaskIntoConstraints = false
            self.snp.makeConstraints { (maker) in
                maker.top.bottom.left.right.equalToSuperview()
            }
        }
    }
}
