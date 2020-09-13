//
//  ToolbarView.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/7/9.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import Kingfisher

enum PageType: Int {
    case Home = 0
    case Game
    case Card
    case Notify
    case Profile
    
    var name: String {
        switch self {
        case .Home:
            return "Home"
        case .Game:
            return "Game"
        case .Card:
            return "Card"
        case .Notify:
            return "Notify"
        case .Profile:
            return "Profile"
        }
    }
}
protocol ToolbarViewDelegate {
    func setupPage(_ page: PageType) -> PageType
}
class ToolbarView: UIView {
    @IBOutlet var toolbarItemBG: [UIView]!
    @IBOutlet weak var imageAvatar: UIImageView!
    private static var _shared: ToolbarView?
    private var delegate: ToolbarViewDelegate?
    private var currentPage: PageType = .Home
    private var lastPage: PageType = .Home
    
    static var shared: ToolbarView {
        if _shared == nil {
            _shared = UINib(nibName: "ToolbarView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? ToolbarView
        }
        return _shared!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageAvatar.layer.borderWidth = 1
        self.imageAvatar.layer.borderColor = UIColor.blue.cgColor
        setGradientBG(toolbarItemBG[self.currentPage.rawValue])
    }
    override func layoutSubviews() {
        self.imageAvatar.layer.cornerRadius = self.imageAvatar.bounds.width / 2
    }
    @IBAction func didClickBtnPage(_ sender: UIButton) {
        if let delegate = delegate, self.currentPage.rawValue != sender.tag{
            self.lastPage = self.currentPage
            self.currentPage = delegate.setupPage(PageType(rawValue: sender.tag)!)
            setGradientBG(toolbarItemBG[self.currentPage.rawValue])
            resetBG(toolbarItemBG[self.lastPage.rawValue])
        }
    }
    func show(_ willShow: Bool) {
        if willShow {
            let window = UIApplication.shared.windows.first!
            layer.zPosition = 5
            window.addSubview(self)
            
            translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([leadingAnchor.constraint(equalTo: window.leadingAnchor), bottomAnchor.constraint(equalTo: window.bottomAnchor), heightAnchor.constraint(equalToConstant: Size.screenHeight / 12), widthAnchor.constraint(equalToConstant: Size.screenWidth)])
        } else {
            self.removeFromSuperview()
        }
    }
    func setDelegate(_ delegate: ToolbarViewDelegate?) {
        self.delegate = delegate
    }
    func setAvatar(url: String) {
        if url != "" {
            self.imageAvatar.kf.setImage(with: URL(string: url))
        } else {
            self.imageAvatar.image = UIImage(named: ImageInfo.profile)
        }
    }
    private func setGradientBG(_ view: UIView) {
        let layer = CAGradientLayer()
        layer.frame = view.bounds
        layer.startPoint = CGPoint(x: 0.0, y: 0.0)
        layer.endPoint = CGPoint(x: 1.0, y: 0.0)
        layer.colors = [#colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1).cgColor , #colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 0.5495237586).cgColor]
        view.layer.insertSublayer(layer, at: 0)
    }
    private func resetBG(_ view: UIView) {
        view.layer.sublayers?.first?.removeFromSuperlayer()
    }
}
