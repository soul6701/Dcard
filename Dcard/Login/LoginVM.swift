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
    ///創建帳戶
    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String, avatar: Data?)
    var creartUserDataSubject: PublishSubject<Bool> { get }
    ///刪除所有帳戶
    func deleteUserData()
    var deleteUserDataSubject: PublishSubject<DeleteCollectionType> { get }
    ///登入
    func login(address: String, password: String)
    var loginSubject: PublishSubject<FirebaseResult<Bool>> { get }
    ///取得喜好清單
    func setupFaroriteData()
    var setupFaroriteDataSubject: PublishSubject<FirebaseResult<Bool>> { get }
    ////取得卡稱資訊
    func setupCardData()
    var setupCardDataSubject: PublishSubject<FirebaseResult<Bool>> { get }
    ///檢查信箱重複
    func expectAccount(address: String)
    var expectAccountSubject: PublishSubject<FirebaseResult<Bool>> { get }
    ///查詢密碼
    func requirePassword(uid: String, phone: String?, address: String?)
    var requirePasswordSubject: PublishSubject<FirebaseResult<Bool>> { get }
    ///修改使用者資訊
    func updateUserInfo(user: [UserFieldType: Any])
    var updateUserInfoSubject: PublishSubject<FirebaseResult<Bool>> { get }
}
class LoginVM: LoginVMInterface {
    private (set) var requirePasswordSubject = PublishSubject<FirebaseResult<Bool>>()
    private (set) var creartUserDataSubject = PublishSubject<Bool>()
    private (set) var deleteUserDataSubject = PublishSubject<DeleteCollectionType>()
    private (set) var loginSubject = PublishSubject<FirebaseResult<Bool>>()
    private (set) var setupFaroriteDataSubject = PublishSubject<FirebaseResult<Bool>>()
    private (set) var setupCardDataSubject = PublishSubject<FirebaseResult<Bool>>()
    private (set) var expectAccountSubject = PublishSubject<FirebaseResult<Bool>>()
    private (set) var updateUserInfoSubject = PublishSubject<FirebaseResult<Bool>>()
    
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
    func setupCardData() {
        self.loginFirebase.setupCardData().subscribe(onNext: { (result) in
            self.setupCardDataSubject.onNext(result)
        }, onError: { (error) in
            self.setupCardDataSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func setupFaroriteData() {
        self.loginFirebase.setupFaroriteData().subscribe(onNext: { (result) in
            self.setupFaroriteDataSubject.onNext(result)
        }, onError: { (error) in
            self.setupFaroriteDataSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
}

