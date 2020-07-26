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
    case Card = "Card"
    case Notify = "Notify"
    case Profile = "Profile"
}
protocol setupPageDelegate {
    func setupPage(vc: UIViewController)
}
class ToolbarView: UIView {
    private static var _shared: ToolbarView?
    private static var delegate: setupPageDelegate?
    
    static var shared: ToolbarView {
        if _shared == nil {
            _shared = UINib(nibName: "ToolbarView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? ToolbarView
        }
        return _shared!
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBAction func toHome(_ sender: UIButton) {
        setPage(.Home)
    }
    @IBAction func toCatalog(_ sender: UIButton) {
        setPage(.Catalog)
    }
    @IBAction func toGame(_ sender: UIButton) {
        setPage(.Card)
    }
    @IBAction func toNotify(_ sender: UIButton) {
        setPage(.Notify)
    }
    @IBAction func toProfile(_ sender: UIButton) {
        setPage(.Profile)
    }
    
    func show(_ willShow: Bool) {
        if willShow {
            let window = UIApplication.shared.windows.first!
            layer.zPosition = 5
            window.addSubview(self)
            
            translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([leadingAnchor.constraint(equalTo: window.leadingAnchor), bottomAnchor.constraint(equalTo: window.bottomAnchor), heightAnchor.constraint(equalToConstant: Size.screenWidth / 5), widthAnchor.constraint(equalToConstant: Size.screenWidth)])
            print("screenHeight: \(Size.screenHeight) screenWidth: \(Size.screenWidth)")
        } else {
            removeFromSuperview()
        }
    }
    func setDelegate(delegate: setupPageDelegate?) {
        ToolbarView.delegate = delegate
    }
    private func setPage(_ page: PageType) {
        var vc: UIViewController!
        
        switch page {
        case .Card:
            vc = UIStoryboard(name: page.rawValue, bundle: nil).instantiateInitialViewController() as! GameVC
        case .Catalog:
            vc = UIStoryboard(name: page.rawValue, bundle: nil).instantiateInitialViewController() as! CatalogVC
        case .Home:
            vc = UIStoryboard(name: page.rawValue, bundle: nil).instantiateInitialViewController() as! HomeVC
        case .Notify:
            vc = UIStoryboard(name: page.rawValue, bundle: nil).instantiateInitialViewController() as! NotifyVC
        case .Profile:
            vc = UIStoryboard(name: page.rawValue, bundle: nil).instantiateInitialViewController() as! ProfileVC
        }
    }
}
