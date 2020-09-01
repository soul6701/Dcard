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
    var creartUserDataSubject: PublishSubject<Bool> { get }
    var deleteUserDataSubject: PublishSubject<DeleteCollectionType> { get }
    var loginSubject: PublishSubject<LoginType> { get }
    var expectAccountSubject: PublishSubject<Bool> { get }
    var requirePasswordSubject: PublishSubject<RequirePasswordType> { get }
    
    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String, avatar: Data?)
    func login(lastName: String, firstName: String, password: String)
    func deleteUserData()
    func expectAccount(lastName: String, firstName: String)
    func requirePassword(uid: String, phone: String?, address: String?)
}
class LoginVM: LoginVMInterface {
    private (set) var requirePasswordSubject = PublishSubject<RequirePasswordType>()
    private (set) var creartUserDataSubject = PublishSubject<Bool>()
    private (set) var deleteUserDataSubject = PublishSubject<DeleteCollectionType>()
    private (set) var loginSubject = PublishSubject<LoginType>()
    private (set) var expectAccountSubject = PublishSubject<Bool>()
    
    private var userFirebase: UserFirebaseInterface
    private var disposeBag = DisposeBag()
    
    init(userFirebase: UserFirebaseInterface = UserFirebase.shared) {
        self.userFirebase = userFirebase
    }
}
extension LoginVM {
    
    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String, avatar: Data?) {
        userFirebase.creartUserData(lastName: lastName, firstName: firstName, birthday: birthday, sex: sex, phone: phone, address: address, password: password, avatar: avatar).subscribe(onNext: { (result) in
            self.creartUserDataSubject.onNext(result)
        }, onError: { (error) in
            self.creartUserDataSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func login(lastName: String, firstName: String, password: String) {
        userFirebase.login(lastName: lastName, firstName: firstName, password: password).subscribe(onNext: { (loginType) in
            self.loginSubject.onNext(loginType)
        }, onError: { (error) in
            self.loginSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func deleteUserData() {
        userFirebase.deleteUserData().subscribe(onNext: { (result) in
            self.deleteUserDataSubject.onNext(result)
        }, onError: { (error) in
            self.deleteUserDataSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func expectAccount(lastName: String, firstName: String) {
        userFirebase.expectAccount(lastName: lastName, firstName: firstName).subscribe(onNext: { (result) in
            self.expectAccountSubject.onNext(result)
        }, onError: { (error) in
            self.expectAccountSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func requirePassword(uid: String, phone: String?, address: String?) {
        userFirebase.requirePassword(uid: uid, phone: phone, address: address).subscribe(onNext: { (result) in
            self.requirePasswordSubject.onNext(result)
        }, onError: { (error) in
            self.requirePasswordSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
}

