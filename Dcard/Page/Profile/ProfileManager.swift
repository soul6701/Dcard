//
//  ProfileManager.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/13.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SwiftMessages
import SwiftyJSON

protocol ProfileManagerInterface {
    func confiOKView()
    func confiAlertView()
    func showOKView(mode: ProfileOKMode, handler: (() -> Void)?)
    func showAlertView(errorMessage: String, handler: (() -> Void)?)
}
enum ProfileOKMode {
    
}
class ProfileManager: ProfileManagerInterface {
    static let shared = ProfileManager()
    var OKView: MessageView!
    var OKconfig: SwiftMessages.Config!
    var alertView: MessageView!
    var alertconfig: SwiftMessages.Config!
    
    
    init() {
        confiOKView()
        confiAlertView()
    }
    
    //成功視窗
    func confiOKView() {
        self.OKView = MessageView.viewFromNib(layout: .centeredView)
        self.OKView.id = "success"
        self.OKView.configureTheme(backgroundColor: #colorLiteral(red: 0.8711531162, green: 0.4412498474, blue: 0.8271986842, alpha: 1), foregroundColor: .black)
        self.OKView.button?.removeFromSuperview()
        
        self.OKconfig = SwiftMessages.Config()
        self.OKconfig.presentationContext = .window(windowLevel: .normal)
        self.OKconfig.presentationStyle = .center
    }
    func showOKView(mode: ProfileOKMode, handler: (() -> Void)?) {
//        self.OKconfig.duration = .seconds(seconds: mode == .create ? 2 : 1)
//        var body = ""
//        switch mode {
//        case .create:
//            body = "註冊成功"
//        case .login:
//            body = "登入成功"
//        case .delete:
//            body = "刪除成功"
//        case .required:
//            body = "查詢成功，自動填入"
//        }
//        self.OKView.configureContent(title: "", body: body)
//        self.OKconfig.eventListeners = .init(arrayLiteral: { (event) in
//            if event == .didHide {
//                SwiftMessages.hide(id: "success")
//                handler?()
//            }
//        })
        SwiftMessages.show(config: self.OKconfig, view: self.OKView)
    }
    //警告視窗
    func confiAlertView() {
        self.alertView = MessageView.viewFromNib(layout: .centeredView)
        self.alertView.id = "alert"
        self.alertView.configureTheme(backgroundColor: #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1), foregroundColor: .black)
        
        self.alertconfig = SwiftMessages.Config()
        self.alertconfig.presentationContext = .window(windowLevel: .alert)
        self.alertconfig.presentationStyle = .center
        self.alertconfig.duration = .forever
    }
    func showAlertView(errorMessage: String, handler: (() -> Void)?) {
        self.alertView.configureContent(title: "錯誤", body: errorMessage, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "OK") { (btn) in
            SwiftMessages.hide(id: "alert")
            handler?()
        }
        SwiftMessages.show(config: self.alertconfig, view: self.alertView)
    }
    //跳轉指定頁面
    func toNextPage(_ currentVC: UINavigationController, next: ProfileThreeCellType) {
        switch next {
        case .favorites:
            let vc = UIStoryboard.profile.favoriteVC
            vc.setContent(favoriteList: [], title: next.cell.name)
            currentVC.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
