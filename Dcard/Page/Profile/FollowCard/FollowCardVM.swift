//
//  FollowCardVM.swift
//  Dcard
//
//  Created by Mason on 2020/10/30.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Firebase
import UIKit
import RxSwift
import RxCocoa

protocol FollowCardVMInterface {
    //取得好友列表
    var getFollowCardListSubject: PublishSubject<[FollowCard]> { get }
    func getFollowCardList()
    //取得貼文
    var getFollowCardPostListSubject: PublishSubject<[Post]> { get }
    func getFollowCardPostList(uid: String)
}
class FollowCardVM: FollowCardVMInterface {
    private(set) var getFollowCardListSubject = PublishSubject<[FollowCard]>()
    private(set) var getFollowCardPostListSubject = PublishSubject<[Post]>()
    
    private var postFirebase: PostFirebaseInterface
    private var loginFirebase: LoginFirebaseInterface
    private var disposeBag = DisposeBag()
    
    init(postFirebase: PostFirebaseInterface = PostFirebase.shared, loginFirebase: LoginFirebaseInterface = LoginFirebase.shared) {
        self.postFirebase = postFirebase
        self.loginFirebase = loginFirebase
    }
}
extension FollowCardVM {
    func getFollowCardList() {
        //
    }
    func getFollowCardPostList(uid: String) {
        self.postFirebase.getPostInfo(uid: uid).subscribe(onNext: { (result) in
            self.getFollowCardPostListSubject.onNext(result.data)
        }, onError: { (error) in
            self.getFollowCardPostListSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
//    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String, avatar: Data?) {
//        self.loginFirebase.creartUserData(lastName: lastName, firstName: firstName, birthday: birthday, sex: sex, phone: phone, address: address, password: password, avatar: avatar).subscribe(onNext: { (result) in
//            self.creartUserDataSubject.onNext(result)
//        }, onError: { (error) in
//            self.creartUserDataSubject.onError(error)
//        }).disposed(by: self.disposeBag)
//    }
//    func login(address: String, password: String) {
//        self.loginFirebase.login(address: address, password: password).subscribe(onNext: { (loginType) in
//            self.loginSubject.onNext(loginType)
//        }, onError: { (error) in
//            self.loginSubject.onError(error)
//        }).disposed(by: self.disposeBag)
//    }
//    func deleteUserData() {
//        self.loginFirebase.deleteUserData().subscribe(onNext: { (result) in
//            self.deleteUserDataSubject.onNext(result)
//        }, onError: { (error) in
//            self.deleteUserDataSubject.onError(error)
//        }).disposed(by: self.disposeBag)
//    }
//    func expectAccount(address: String) {
//        self.loginFirebase.expectAccount(address: address).subscribe(onNext: { (result) in
//            self.expectAccountSubject.onNext(result)
//        }, onError: { (error) in
//            self.expectAccountSubject.onError(error)
//        }).disposed(by: self.disposeBag)
//    }
//    func requirePassword(uid: String, phone: String?, address: String?) {
//        self.loginFirebase.requirePassword(uid: uid, phone: phone, address: address).subscribe(onNext: { (result) in
//            self.requirePasswordSubject.onNext(result)
//        }, onError: { (error) in
//            self.requirePasswordSubject.onError(error)
//        }).disposed(by: self.disposeBag)
//    }
//    func updateUserInfo(newAddress: String, newPassword: String, newCard: [CardFieldType : String]) {
//        self.loginFirebase.updateUserInfo(newAddress: newAddress, newPassword: newPassword, newCard: newCard) .subscribe(onNext: { (result) in
//            self.updateUserInfoSubject.onNext(result)
//        }, onError: { (error) in
//            self.updateUserInfoSubject.onError(error)
//        }).disposed(by: self.disposeBag)
//    }
}

