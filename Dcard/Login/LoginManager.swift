//
//  LoginManager.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/25.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SwiftMessages

protocol LoginManagerInterface {
    func showConfirmView(_ vc: UIViewController)
    func addSwipeGesture(to view: UIView, disposeBag: DisposeBag, handler: @escaping () -> Void)
    func addTapGesture(to view: UIView, disposeBag: DisposeBag)
    func confiOKView()
    func confiAlertView()
    func showOKView(mode: OKMode, handler: (() -> Void)?)
    func showAlertView(errorMessage: String, handler: (() -> Void)?)
}
enum OKMode {
    case login
    case create
}
class LoginManager: LoginManagerInterface {
    static let shared = LoginManager()
    var commonCornerRadius: CGFloat = 5
    var commonBorderWidth: CGFloat = 1
    var commonBorderColor = UIColor.lightGray.cgColor
    var OKView: MessageView!
    var OKconfig: SwiftMessages.Config!
    var alertView: MessageView!
    var alertconfig: SwiftMessages.Config!
    
    init() {
        confiOKView()
        confiAlertView()
    }
    
    func showConfirmView(_ vc: UIViewController) {
        let alertsheet = UIAlertController(title: "", message: "已經有帳號了？", preferredStyle: .actionSheet)
        let signInAction = UIAlertAction(title: "登入", style: .default) { (_) in
            vc.dismiss(animated: true, completion: nil)
        }
        let continueAction = UIAlertAction(title: "繼續註冊", style: .default)
        alertsheet.addAction(signInAction)
        alertsheet.addAction(continueAction)
        vc.present(alertsheet, animated: true)
    }
    func addSwipeGesture(to view: UIView, disposeBag: DisposeBag, handler: @escaping () -> Void) {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .right
        swipe.cancelsTouchesInView = false
        swipe.rx.event.asControlEvent().subscribe(onNext: { (swipe) in
            if swipe.location(in: view).x < view.frame.width / 4 {
                handler()
            }
            }).disposed(by: disposeBag)
        view.addGestureRecognizer(swipe)
    }
    func addTapGesture(to view: UIView, disposeBag: DisposeBag) {
        let ges = UITapGestureRecognizer()
        ges.rx.event.asControlEvent().subscribe(onNext: { (tap) in
            if let vc = tap.view?.parentContainerViewController() {
                self.showConfirmView(vc)
            }
            }).disposed(by: disposeBag)
        view.addGestureRecognizer(ges)
    }
    
    func confiOKView() {
        self.OKView = MessageView.viewFromNib(layout: .centeredView)
        self.OKView.id = "success"
        self.OKView.configureTheme(backgroundColor: #colorLiteral(red: 0.8711531162, green: 0.4412498474, blue: 0.8271986842, alpha: 1), foregroundColor: .black)
        self.OKView.button?.removeFromSuperview()
        
        self.OKconfig = SwiftMessages.Config()
        self.OKconfig.presentationContext = .window(windowLevel: .normal)
        self.OKconfig.presentationStyle = .center
    }
    func confiAlertView() {
        self.alertView = MessageView.viewFromNib(layout: .centeredView)
        self.alertView.id = "alert"
        self.alertView.configureTheme(backgroundColor: #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1), foregroundColor: .black)
        
        self.alertconfig = SwiftMessages.Config()
        self.alertconfig.presentationContext = .window(windowLevel: .alert)
        self.alertconfig.presentationStyle = .center
        self.alertconfig.duration = .forever
    }
    func showOKView(mode: OKMode, handler: (() -> Void)?) {
        self.OKconfig.duration = .seconds(seconds: mode == .create ? 2 : 1)
        self.OKView.configureContent(title: "", body: mode == .create ? "註冊成功" : "成功")
        self.OKconfig.eventListeners = .init(arrayLiteral: { (event) in
            if event == .didHide {
                SwiftMessages.hide(id: "success")
                handler?()
            }
        })
        SwiftMessages.show(config: self.OKconfig, view: self.OKView)
    }
    func showAlertView(errorMessage: String, handler: (() -> Void)?) {
        self.alertView.configureContent(title: "錯誤", body: errorMessage, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "OK") { (btn) in
            SwiftMessages.hide(id: "alert")
            handler?()
        }
        SwiftMessages.show(config: self.alertconfig, view: self.alertView)
    }
}
