//
//  CardManager.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/5.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SwiftMessages
import SwiftyJSON

private protocol CardManagerInterface {
    func confiOKView()
    func confiAlertView()
    func showOKView(mode: OKMode, handler: (() -> Void)?)
    func showAlertView(errorMessage: String, handler: (() -> Void)?)
    func confiFilterView()
    func showFilterView(handler: @escaping ((CardMode) -> Void))
}
class CardManager: CardManagerInterface {
    static let shared = CardManager()
    fileprivate var OKView: MessageView!
    fileprivate var OKconfig: SwiftMessages.Config!
    
    fileprivate var filterView: FilterView!
    fileprivate var filterConfig: SwiftMessages.Config!
    
    fileprivate var alertView: MessageView!
    fileprivate var alertConfig: SwiftMessages.Config!
    
    fileprivate var filterHandler: ((CardMode) -> Void)?
    
    init() {
        confiOKView()
        confiAlertView()
        confiFilterView()
    }
    
    fileprivate func confiOKView() {
        self.OKView = MessageView.viewFromNib(layout: .centeredView)
        self.OKView.id = "success"
        self.OKView.configureTheme(backgroundColor: #colorLiteral(red: 0.8711531162, green: 0.4412498474, blue: 0.8271986842, alpha: 1), foregroundColor: .black)
        self.OKView.button?.removeFromSuperview()
        
        self.OKconfig = SwiftMessages.Config()
        self.OKconfig.presentationContext = .window(windowLevel: .normal)
        self.OKconfig.presentationStyle = .center
    }
    fileprivate func confiAlertView() {
        self.alertView = MessageView.viewFromNib(layout: .centeredView)
        self.alertView.id = "alert"
        self.alertView.configureTheme(backgroundColor: #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1), foregroundColor: .black)
        
        self.alertConfig = SwiftMessages.Config()
        self.alertConfig.presentationContext = .window(windowLevel: .alert)
        self.alertConfig.presentationStyle = .center
        self.alertConfig.duration = .forever
    }
    fileprivate func confiFilterView() {
        self.filterView = try? SwiftMessages.viewFromNib(named: "FilterView") as? FilterView
        self.filterView.id = "filter"
        
        self.filterView.configureTheme(backgroundColor: #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), foregroundColor: #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1))
        
        self.filterConfig = SwiftMessages.Config()
        self.filterConfig.presentationContext = .window(windowLevel: .statusBar)
        self.filterConfig.presentationStyle = .center
        self.filterConfig.dimMode = .gray(interactive: true)
        self.filterConfig.duration = .forever
    }
    func showOKView(mode: OKMode, handler: (() -> Void)?) {
        self.OKconfig.duration = .seconds(seconds: mode == .create ? 2 : 1)
        var body = ""
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
        self.OKView.configureContent(title: "", body: body)
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
        SwiftMessages.show(config: self.alertConfig, view: self.alertView)
    }
    func showFilterView(handler: @escaping ((CardMode) -> Void)) {
        self.filterHandler = handler
        self.filterView.setDelegate(delegate: self)
        SwiftMessages.show(config: self.filterConfig, view: self.filterView)
    }
}
extension CardManager: FilterViewDelegate {
    func select(cardMode: CardMode) {
        filterHandler?(cardMode)
        SwiftMessages.hide(id: "filter")
    }
}
