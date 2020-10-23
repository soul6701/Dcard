//
//  PrivacyView.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/15.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

protocol PrivacyViewDelegate {
    func didClickPassword()
}
class PrivacyView: UIView {
    
    static private weak var _shared: PrivacyView? //weak必要 不然會因為循環引用 不會釋放記憶體
    static var shared: PrivacyView! {
        if _shared == nil {
            _shared = UINib(nibName: "PrivacyView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? PrivacyView
        }
        return _shared!
    }
    
    private var delegate: PrivacyViewDelegate?
    
    @IBAction func didClickPassword(_ sender: customButton) {
        self.delegate?.didClickPassword()
    }
    func setDelegate(_ delegate: PrivacyViewDelegate) {
        self.delegate = delegate
    }
    func show(vc: UIViewController) {
        self.translatesAutoresizingMaskIntoConstraints = false
        vc.view.setFixedView(self)
    }
    func close() {
        let animation = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) {
            self.alpha = 0
        }
        animation.addCompletion { (position) in
            if position == .end {
                self.removeFromSuperview()
            }
        }
        animation.startAnimation()
    }
}
