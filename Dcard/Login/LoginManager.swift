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
import SwiftyJSON

enum LoginPageType: String {
    case CreateAccountVC
    case SetBirthDayVC
    case SetPhoneAddressVC
    case SetSexVC
    case SetPasswordVC
    case CompleteRegisterVC
}
class LoginManager {
    static let shared = LoginManager()
    private var baseNav: UINavigationController?

    //翻頁手勢
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
    //確認視窗是否繼續註冊 或 回到登入首頁
    func addTapGesture(to view: UIView, disposeBag: DisposeBag) {
        let ges = UITapGestureRecognizer()
        ges.rx.event.asControlEvent().subscribe(onNext: { (tap) in
            if let vc = tap.view?.parentContainerViewController() {
                self.showConfirmView(vc)
            }
            }).disposed(by: disposeBag)
        view.addGestureRecognizer(ges)
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
    
    //取得國碼
    func getCountryCode(handler: ([String:String], [String:String]) -> Void) {
        var userinfo_country_code: [String:String] = [:]
        var id_to_countrycode: [String:String] = [:]
        
        let path = Bundle.main.path(forResource: "country", ofType: "json")
        if let jsonData = try? NSData(contentsOfFile: path!, options: .mappedIfSafe) {
            do {
                let jsonObj = try JSON(data: jsonData as Data)
                userinfo_country_code = jsonObj["userinfo_country_code"].dictionaryObject as! [String:String]
                id_to_countrycode = jsonObj["id_to_countrycode"].dictionaryObject as! [String:String]
            } catch let error {
                printError(title: "解析JSON失敗", error: error.localizedDescription, content: String(bytes: jsonData, encoding: .utf8))
            }
        }
        handler(userinfo_country_code, id_to_countrycode)
    }
    //跳轉指定頁面
    func toNextPage(_ next: LoginPageType) {
        let stroyboard = UIStoryboard(name: "Login", bundle: nil)
        let nextVC = stroyboard.instantiateViewController(withIdentifier: next.rawValue)
        self.baseNav?.pushViewController(nextVC, animated: true)
    }
    //設置NavigationController
    func setBaseNav(_ nav: UINavigationController) {
        self.baseNav = nav
    }
}
