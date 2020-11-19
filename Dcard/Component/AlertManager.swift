//
//  AlertManager.swift
//  Dcard
//
//  Created by Mason on 2020/11/18.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import SwiftMessages
import SnapKit

public class AlertManager {
    enum LoginOKMode: String {
        case login = "登入成功"
        case create = "註冊成功"
        case delete = "刪除成功"
        case required = "查詢成功，自動填入"
        case other = "成功"
    }
    enum ProfileOKMode: String {
        case sendVefifymail = "已成功發送"
        case cancelFollowCard, cancelFollowIssue = "成功取消追蹤"
        case shareCardInfoAndIssueInfo = "分享成功"
    }
    enum FavoriteOKMode: String {
        case remove = "移除收藏清單成功"
        case create = "創建收藏清單成功"
        case update = "更新收藏清單名字成功"
    }
    enum OKMode {
        case login(LoginOKMode)
        case profile(ProfileOKMode)
        case favorite(FavoriteOKMode)
    }
    public static let shared = AlertManager()
    
    private var OKView: MessageView!
    private var OKconfig: SwiftMessages.Config!
    private var alertView: MessageView!
    private var alertconfig: SwiftMessages.Config!
    
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
    func showOKView(mode: OKMode, handler: (() -> Void)?) {
        self.OKconfig.duration = .seconds(seconds: 1)
        switch mode {
        case .login(let mode):
            self.OKView.configureContent(title: "", body: mode.rawValue)
        case .profile(let mode):
            self.OKView.configureContent(title: "", body: mode.rawValue)
        case .favorite(let mode):
            self.OKView.configureContent(title: "", body: mode.rawValue)
        }
    
        self.OKconfig.eventListeners = .init(arrayLiteral: { (event) in
            if event == .didHide {
                SwiftMessages.hide(id: "success")
                handler?()
            }
        })
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
    
}


