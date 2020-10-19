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
import LocalAuthentication

protocol ProfileManagerInterface {
    func setBaseNav(_ nav: UINavigationController)
    func showOKView(mode: ProfileOKMode, handler: (() -> Void)?)
    func showAlertView(errorMessage: String, handler: (() -> Void)?)
    func showBellModeView(delegate: SelectNotifyViewDelegate, notifyMode: Int)
    func showCancelFollowCardView(_ viewController: UIViewController,  title: String, OKAction: (() -> Void)?)
    func showAuthenticationView(times: Int, callbackAction: @escaping ((_ state: AuthenticationState) -> Void))
    func toFriendCardPage(mail: Mail)
    func toNextPage(next: ProfileThreeCellType)
}
enum AuthenticationState {
    case success
    case error
    case fallback
}
enum ProfileOKMode {
    case sendVefifymail
    case cancelFollowCard
    case cancelFollowIssue
}
class ProfileManager: ProfileManagerInterface {
    
    static let shared = ProfileManager()
    private var OKView: MessageView!
    private var OKConfig: SwiftMessages.Config!
    private var alertView: MessageView!
    private var alertconfig: SwiftMessages.Config!
    private var baseNav: UINavigationController!
    //假值
    var user: User {
        return ModelSingleton.shared.userConfig.user
    }
    let list = [["我像個殘廢 飛不出你的世界", "借不到一點安慰"], ["雖然暗戀讓人早熟", "也讓人多難過"], ["多麽想告訴你 我好喜歡你", "都怪我控制不了自己"], ["未來的每一步一腳印", "相知相習相依為命"]]
    let _mediaMeta = [[MediaMeta(thumbnail: "https://i1.kknews.cc/SIG=17fh01n/3r580003rr4ps40n960o.jpg", normalizedUrl: "https://i1.kknews.cc/SIG=17fh01n/3r580003rr4ps40n960o.jpg")], [MediaMeta(thumbnail: "https://i1.kknews.cc/SIG=1avg1r2/3r580003rqson1npps7s.jpg", normalizedUrl: "https://i1.kknews.cc/SIG=1avg1r2/3r580003rqson1npps7s.jpg")], [MediaMeta(thumbnail: "https://i1.kknews.cc/SIG=11sbjcv/ctp-vzntr/15341312472962rqp6q4r2q.jpg", normalizedUrl: "https://i1.kknews.cc/SIG=11sbjcv/ctp-vzntr/15341312472962rqp6q4r2q.jpg")], [MediaMeta(thumbnail: "https://i1.kknews.cc/SIG=38pi76/ctp-vzntr/1534131247394rsnss9rr7o.jpg", normalizedUrl: "https://i1.kknews.cc/SIG=38pi76/ctp-vzntr/1534131247394rsnss9rr7o.jpg")]]
    var postList: [Post] {
        var _postList = [Post]()
        (0...7).forEach { (i) in
            _postList.append(Post(id: ["qwert12345", "asdfg12345", "zxcvb12345"].randomElement()!, title: list[i % 4][0], excerpt: list[i % 4][1], createdAt: ["2020-12-31", "2020-09-15"].randomElement()!, commentCount: String((0...5).randomElement()!), likeCount: String((0...5).randomElement()!), forumName: ["廢文", "NBA", "穿搭", "寵物"].randomElement()!, gender: ["F", "M"].randomElement()!, school: "", mediaMeta: _mediaMeta[i % 4], department: ["神奇寶貝研究系", "愛哩愛尬沒系", "機械工程系", "資訊工程系", "肥宅養成系", "愛丟卡慘系"].randomElement()!, anonymousSchool: Bool.random(), anonymousDepartment:  Bool.random(), withNickname:  Bool.random()))
        }
        return _postList
    }
    var myPostList: [Post] {
        var _myPostList = [Post]()
        (0...7).forEach { (i) in
            let withNickname = Bool.random()
            _myPostList.append(Post(id: user.lastName + "_" + user.firstName , title: list[i % 4][0], excerpt: list[i % 4][1], createdAt: ["2020-12-31", "2020-09-15", "2018-02-21"].randomElement()!, commentCount: String((0...5).randomElement()!), likeCount: String((0...5).randomElement()!), forumName: ["廢文", "NBA", "穿搭", "寵物"].randomElement()!, gender: "M", school: withNickname ? "野比大雄" : "私立台灣肥宅學院", mediaMeta: _mediaMeta[i % 4], department: withNickname ? "K" : "邊緣人養成系", anonymousSchool: false, anonymousDepartment: false, withNickname: withNickname))
        }
        return _myPostList
    }
    
    init() {
        confiOKView()
        confiAlertView()
    }
    func confiOKView() {
        self.OKView = MessageView.viewFromNib(layout: .centeredView)
        self.OKView.id = "success"
        self.OKView.configureTheme(backgroundColor: #colorLiteral(red: 0.8711531162, green: 0.4412498474, blue: 0.8271986842, alpha: 1), foregroundColor: .black)
        self.OKView.button?.removeFromSuperview()
        
        self.OKConfig = SwiftMessages.Config()
        self.OKConfig.presentationContext = .window(windowLevel: .normal)
        self.OKConfig.presentationStyle = .center
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
    //存入本地資料庫
    func saveToDataBase(preference: Preference) {
        DbManager.shared.updatePreference(preference: preference)
    }
    //設置NavigationController
    func setBaseNav(_ nav: UINavigationController) {
        self.baseNav = nav
    }
    //成功視窗
    func showOKView(mode: ProfileOKMode, handler: (() -> Void)?) {
        self.OKConfig.duration = .seconds(seconds: 1)
        var body = ""
        switch mode {
        case .sendVefifymail:
            body = "已成功發送"
        case .cancelFollowCard, .cancelFollowIssue:
            body = "成功取消追蹤"
        }
        self.OKView.configureContent(title: "", body: body)
        self.OKConfig.eventListeners = .init(arrayLiteral: { (event) in
            if event == .didHide {
                SwiftMessages.hide(id: "success")
                handler?()
            }
        })
        SwiftMessages.show(config: self.OKConfig, view: self.OKView)
    }
    //警告視窗
    func showAlertView(errorMessage: String, handler: (() -> Void)?) {
        self.alertView.configureContent(title: "錯誤", body: errorMessage, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "OK") { (btn) in
            SwiftMessages.hide(id: "alert")
            handler?()
        }
        SwiftMessages.show(config: self.alertconfig, view: self.alertView)
    }
    //通知視窗
    func showBellModeView(delegate: SelectNotifyViewDelegate, notifyMode: Int) {
        if let view = UINib(nibName: "SelectNotifyView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? SelectNotifyView {
            view.setDelegate(delegate)
            view.setContent(notifymode: notifyMode)
            view.show()
        }
    }
    //取消追蹤視窗
    func showCancelFollowCardView(_ viewController: UIViewController,  title: String, OKAction: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: "" , preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        cancelAction.titleTextColor = .darkGray
        let OKAction = UIAlertAction(title: "取消追蹤", style: .destructive) { (action) in
            OKAction?()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        viewController.present(alertController, animated: true)
    }
    //驗證視窗
    func showAuthenticationView(times: Int, callbackAction: @escaping ((_ state: AuthenticationState) -> Void)) {
        var error: NSError?
        let context = LAContext()
        context.localizedCancelTitle = "取消"
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "使用指紋解鎖，以查看受保護的內容"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (result, error) in
                if let error = error {
                    NSLog("😡😡😡😡😡\(error.localizedDescription)😡😡😡😡😡")
                    if let code = LAError.Code(rawValue: (error as NSError).code), code == .userFallback {
                        callbackAction(.fallback)
                    } else {
                        callbackAction(.error)
                    }
                }
                if result {
                    callbackAction(.success)
                }
            }
        }
    }
    //跳轉卡友頁面
    func toFriendCardPage(mail: Mail) {
        if !(self.baseNav.viewControllers.last is MailVC) {
            for vc in self.baseNav.viewControllers where vc is MailVC {
                self.baseNav.popToViewController(vc, animated: false)
            }
        }
        let vc = FriendCardVC()
        vc.setContent(mail: mail)
        self.baseNav.pushViewController(vc, animated: true)
    }
    //跳轉指定頁面
    func toNextPage(next: ProfileThreeCellType) {
        
        switch next {
        case .favorites:
            let vc = UIStoryboard.profile.favoriteVC
            _ = vc.view
            var list = [Favorite]()
            (1...15).forEach { (i) in
                list.append(Favorite(listName: ["居家", "笑話", "美食", "工作", "狗狗"].randomElement()!, post: postList))
            }
            
            vc.setContent(favoriteList: list, title: next.cell.name)
            self.baseNav.pushViewController(vc, animated: true) {
                self.baseNav.setNavigationBarHidden(false, animated: false)
            }
        case .followIssue:
            let vc = UIStoryboard.profile.followIssueVC
            _ = vc.view
            var list = [FollowIssue]()
            (1...20).forEach { (i) in
                list.append(FollowIssue(listName: ["金曲獎", "金鐘獎", "金馬獎"].randomElement()!, postCount: Int.random(in: (1...100)), followCount: Int.random(in: (1...100)), notifyMode: (0...2).randomElement()!, isFollowing: Bool.random()))
            }
            vc.setContent(followIssueList: list, title: next.cell.name)
            self.baseNav.pushViewController(vc, animated: true) {
                self.baseNav.setNavigationBarHidden(false, animated: false)
            }
        case .followCard:
            let vc = UIStoryboard.profile.followCardVC
            _ = vc.view
            var list = [FollowCard]()
            (1...15).forEach { (i) in
                let _postList = postList.filter({ _ in return Bool.random()})
                list.append(FollowCard(card: Card(id: ["qaz123", "wsx123", "edc123", "rfv123"].randomElement()!, post: _postList, name: ["NBA 小天使", "🦊🦊🦊🦊🦊", "🐱🐱🐱", "🐶🐶", "🐼"].randomElement()!, photo: "", sex: ["男性", "女性", "其他"].randomElement()!, introduce: "", country: "", school: "", article: "", birthday: "", love: "", fans: (0...100).randomElement()!), notifyMode: (0...2).randomElement()!, isFollowing: Bool.random(), isNew: Bool.random()))
            }
            vc.setContent(followCardList: list, title: next.cell.name)
            self.baseNav.pushViewController(vc, animated: true) {
                self.baseNav.setNavigationBarHidden(false, animated: false)
            }
        case .artical:
            let vc = UIStoryboard.profile.articalVC
            let _ = vc.view
            vc.setContent(articalList: myPostList, title: next.cell.name)
            self.baseNav.pushViewController(vc, animated: true) {
                self.baseNav.setNavigationBarHidden(false, animated: false)
            }
        case .introduce:
            let vc = UIStoryboard.card.cardInfoVC
            _ = vc.view
            vc.view.backgroundColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 0.8770333904)
            vc.setContent(card: user.card, isUser: true, isFriend: false)
            self.baseNav.pushViewController(vc, animated: true) {
                self.baseNav.setNavigationBarHidden(false, animated: false)
            }
        case .myCard:
            let vc = CardHomeVC()
            vc.setContent(mode: .user)
            self.baseNav.pushViewController(vc, animated: true)
        case .mail:
            let vc = UIStoryboard.profile.mailVC
            self.baseNav.pushViewController(vc, animated: true)
        case .setting:
            let vc = UIStoryboard.profile.settingMainVC
            self.baseNav.pushViewController(vc, animated: true)
        }
    }
}
