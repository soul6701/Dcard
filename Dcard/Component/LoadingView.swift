//
//  Loading.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/4.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    @IBOutlet weak var lbPercent: UILabel!
    @IBOutlet weak var imageProgress: UIImageView!
    @IBOutlet weak var viewProgress: UIProgressView!
    @IBOutlet weak var trailingSpace: NSLayoutConstraint!
    private static var _shared: LoadingView?
    private var count = 0
    private var complete = 100
    private var distance: CGFloat = 0
    
    static var shared: LoadingView {
        if _shared == nil {
            _shared = UINib(nibName: "LoadingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? LoadingView
        }
        return _shared!
    }
    override func layoutSubviews() {
        self.distance = imageProgress.bounds.width
        if self.imageProgress.frame.minX < self.viewProgress.frame.minX + self.imageProgress.frame.size.width {
            self.trailingSpace.constant = 0
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageProgress.loadGif(name: "熊貓")
        _ = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true, block: { (timer) in
            self.viewProgress.setProgress(Float(self.count) / Float(self.complete), animated: true)
            self.trailingSpace.constant -= 3
            self.count += 1
            self.lbPercent.text = "\(Int(floor(Float(self.count) / Float(self.complete) * 100)))%"
            if self.count == 100 {
                self.show(false)
                timer.invalidate()
            }
        })
    }
    func show(_ willShow: Bool) {
        if willShow {
            let window = UIApplication.shared.windows.first!
            layer.zPosition = 6
            window.addSubview(self)
            
            translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([leadingAnchor.constraint(equalTo: window.leadingAnchor), bottomAnchor.constraint(equalTo: window.bottomAnchor), heightAnchor.constraint(equalToConstant: Size.screenHeight), widthAnchor.constraint(equalToConstant: Size.screenWidth)])
        } else {
            removeFromSuperview()
        }
    }
}
