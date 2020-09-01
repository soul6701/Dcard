//
//  ToolbarView.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/7/9.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

enum PageType: String {
    case Home = "Home"
    case Catalog = "Catalog"
    case Game = "Game"
    case Notify = "Notify"
    case Profile = "Profile"
}
protocol ToolbarViewDelegate {
    func setupPage(_ page: PageType?)
}
class ToolbarView: UIView {
    private static var _shared: ToolbarView?
    private var delegate: ToolbarViewDelegate?
    @IBOutlet weak var imageAvatar: UIButton!
    
    static var shared: ToolbarView {
        if _shared == nil {
            _shared = UINib(nibName: "ToolbarView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? ToolbarView
        }
        return _shared!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageAvatar.imageView?.layer.borderWidth = 1
        self.imageAvatar.imageView?.layer.borderColor = UIColor.blue.cgColor
        
    }
    override func layoutSubviews() {
        self.imageAvatar.imageView?.layer.cornerRadius = self.imageAvatar.imageView!.bounds.width / 2
    }
    @IBAction func didClickPageButton(_ sender: UIButton) {
        var page: PageType?
        switch sender.tag {
        case 0:
            page = .Home
        case 1:
            page = .Game
        case 2:
            page = .Catalog
        case 3:
            page = .Notify
        case 4:
            page = .Profile
        default:
            break
        }
        self.delegate?.setupPage(page)
    }
    
    func show(_ willShow: Bool) {
        if willShow {
            let window = UIApplication.shared.windows.first!
            layer.zPosition = 5
            window.addSubview(self)
            
            translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([leadingAnchor.constraint(equalTo: window.leadingAnchor), bottomAnchor.constraint(equalTo: window.bottomAnchor), heightAnchor.constraint(equalToConstant: 80), widthAnchor.constraint(equalToConstant: Size.screenWidth)])
            print("screenHeight: \(Size.screenHeight) screenWidth: \(Size.screenWidth)")
        } else {
            removeFromSuperview()
        }
    }
    func setDelegate(delegate: ToolbarViewDelegate?) {
        self.delegate = delegate
    }
    func setAvatar(url: String) {
        self.imageAvatar.kf.setImage(with: URL(string: url), for: .normal)
    }
}
