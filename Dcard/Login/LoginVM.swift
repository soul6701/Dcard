//
//  LoginVM.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/28.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Firebase
import UIKit
import RxSwift
import RxCocoa

protocol LoginVMInterface {
    //創建帳戶
    var creartUserDataSubject: PublishSubject<Bool> { get }
    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String, avatar: Data?)
    //刪除所有帳戶
    var deleteUserDataSubject: PublishSubject<DeleteCollectionType> { get }
    func deleteUserData()
    //登入
    var loginSubject: PublishSubject<LoginType> { get }
    func login(address: String, password: String)
    //檢查信箱重複
    var expectAccountSubject: PublishSubject<Bool> { get }
    func expectAccount(address: String)
    //查詢密碼
    var requirePasswordSubject: PublishSubject<RequirePasswordType> { get }
    func requirePassword(uid: String, phone: String?, address: String?)
    //修改使用者資訊
    var updateUserInfoSubject: PublishSubject<Bool> { get }
    func updateUserInfo(user: [UserFieldType: Any])
}
class LoginVM: LoginVMInterface {
    private (set) var requirePasswordSubject = PublishSubject<RequirePasswordType>()
    private (set) var creartUserDataSubject = PublishSubject<Bool>()
    private (set) var deleteUserDataSubject = PublishSubject<DeleteCollectionType>()
    private (set) var loginSubject = PublishSubject<LoginType>()
    private (set) var expectAccountSubject = PublishSubject<Bool>()
    private (set) var updateUserInfoSubject = PublishSubject<Bool>()
    
    private var loginFirebase: LoginFirebaseInterface
    private var disposeBag = DisposeBag()
    
    init(loginFirebase: LoginFirebaseInterface = LoginFirebase.shared) {
        self.loginFirebase = loginFirebase
    }
}
extension LoginVM {
    
    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String, avatar: Data?) {
        self.loginFirebase.creartUserData(lastName: lastName, firstName: firstName, birthday: birthday, sex: sex, phone: phone, address: address, password: password, avatar: avatar).subscribe(onNext: { (result) in
            self.creartUserDataSubject.onNext(result)
        }, onError: { (error) in
            self.creartUserDataSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func login(address: String, password: String) {
        self.loginFirebase.login(address: address, password: password).subscribe(onNext: { (loginType) in
            self.loginSubject.onNext(loginType)
        }, onError: { (error) in
            self.loginSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func deleteUserData() {
        self.loginFirebase.deleteUserData().subscribe(onNext: { (result) in
            self.deleteUserDataSubject.onNext(result)
        }, onError: { (error) in
            self.deleteUserDataSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func expectAccount(address: String) {
        self.loginFirebase.expectAccount(address: address).subscribe(onNext: { (result) in
            self.expectAccountSubject.onNext(result)
        }, onError: { (error) in
            self.expectAccountSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func requirePassword(uid: String, phone: String?, address: String?) {
        self.loginFirebase.requirePassword(uid: uid, phone: phone, address: address).subscribe(onNext: { (result) in
            self.requirePasswordSubject.onNext(result)
        }, onError: { (error) in
            self.requirePasswordSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func updateUserInfo(user: [UserFieldType: Any]) {
        self.loginFirebase.updateUserInfo(user: user).subscribe(onNext: { (result) in
            self.updateUserInfoSubject.onNext(result)
        }, onError: { (error) in
            self.updateUserInfoSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
}

