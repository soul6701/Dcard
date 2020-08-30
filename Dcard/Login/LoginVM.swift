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
//    var readFromUserDataSubject: AsyncSubject<User?> { get }
    var loginSubject: PublishSubject<LoginType> { get }
    
    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String)
//    func readFromUserData(lastName: String, firstName: String, password: String)
    func login(lastName: String, firstName: String, password: String)
}
class LoginVM {
    private let _creartUserDataSubject = PublishSubject<Bool>()
//    private let _readFromUserDataSubject = AsyncSubject<User?>()
    private let _loginSubject = PublishSubject<LoginType>()
    
    private var userFirebase: UserFirebaseInterface
    private var disposeBag = DisposeBag()
    
    init(userFirebase: UserFirebaseInterface = UserFirebase.shared) {
        self.userFirebase = userFirebase
    }
}
extension LoginVM: LoginVMInterface {
    var creartUserDataSubject: PublishSubject<Bool> {
        return _creartUserDataSubject
    }
//    var readFromUserDataSubject: AsyncSubject<User?> {
//        return _readFromUserDataSubject
//    }
    var loginSubject: PublishSubject<LoginType> {
        return _loginSubject
    }
    
    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String) {
        userFirebase.creartUserData(lastName: lastName, firstName: firstName, birthday: birthday, sex: sex, phone: phone, address: address, password: password).subscribe(onNext: { (result) in
            self._creartUserDataSubject.onNext(result)
        }, onError: { (error) in
            self._creartUserDataSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    
//    func readFromUserData(lastName: String, firstName: String, password: String) {
//        userFirebase.readFromUserData(lastName: lastName, firstName: firstName, password: password).subscribe(onNext: { (result) in
//            self._readFromUserDataSubject.onNext(result)
//            self._readFromUserDataSubject.onCompleted()
//        }, onError: { (error) in
//            self._readFromUserDataSubject.onError(error)
//        }).disposed(by: self.disposeBag)
//    }
    func login(lastName: String, firstName: String, password: String) {
        userFirebase.login(lastName: lastName, firstName: firstName, password: password).subscribe(onNext: { (loginType) in
            self._loginSubject.onNext(loginType)
        }, onError: { (error) in
            self._loginSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
}

