//
//  CardVM.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/5.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Firebase
import UIKit
import RxSwift
import RxCocoa

protocol CardVMInterface {
    ///取得卡片
    func getRandomCardBySex(cardMode: CardMode)
    var getRandomCardBySexSubject: PublishSubject<[Card]> { get }
    
    ///加入好友
    func addFriend(name: String)
    var addFriendSubject: PublishSubject<Bool> { get }
    
    ///取得卡稱資訊
    func getCardInfo(uid: String)
    var getCardInfoSubject: PublishSubject<FirebaseResult<Card>> { get }
    
    ///取得追蹤卡稱資訊
    func getfollowCardInfo()
    var getfollowCardInfoSubject: PublishSubject<FirebaseResult<[FollowCard]>> { get }
    
    ///修改卡稱資訊
    func updateCardInfo(followCard: FollowCard)
    var updateCardInfoSubject : Observable<FirebaseResult<Bool>> { get }
}
class CardVM: CardVMInterface {
    private(set) var getRandomCardBySexSubject = PublishSubject<[Card]>()
    private(set) var addFriendSubject = PublishSubject<Bool>()
    private(set) var getCardInfoSubject = PublishSubject<FirebaseResult<Card>>()
    private(set) var getfollowCardInfoSubject = PublishSubject<FirebaseResult<[FollowCard]>>()
    private(set) var updateCardInfoSubject = PublishSubject<FirebaseResult<Bool>>()
    
    private var cardFirebase: CardFirebaseInterface
    private var loginFirebase: LoginFirebaseInterface
    private var disposeBag = DisposeBag()
    
    init(cardFirebase: CardFirebaseInterface = CardFirebase.shared, loginFirebase: LoginFirebaseInterface = LoginFirebase.shared) {
        self.cardFirebase = cardFirebase
        self.loginFirebase = loginFirebase
    }
}
extension CardVM {
    
    func getRandomCardBySex(cardMode: CardMode) {
        self.cardFirebase.getRandomCardBySex(cardMode: cardMode).subscribe(onNext: { (result) in
            self.getRandomCardBySexSubject.onNext(result)
        }, onError: { (error) in
            self.getRandomCardBySexSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func addFriend(name: String) {
        self.loginFirebase.addFriend(name: name).subscribe(onNext: { (result) in
            self.addFriendSubject.onNext(result)
        }, onError: { (error) in
            self.addFriendSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func getCardInfo(uid: String) {
        self.cardFirebase.getCardInfo(uid: uid).subscribe(onNext: { (result) in
            self.getCardInfoSubject.onNext(result)
        }, onError: { (error) in
            self.getCardInfoSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func getfollowCardInfo() {
        self.cardFirebase.getfollowCardInfo().subscribe(onNext: { (result) in
            self.getfollowCardInfoSubject.onNext(result)
        }, onError: { (error) in
            self.getfollowCardInfoSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func updateCardInfo(followCard: FollowCard) {
        self.cardFirebase.updateCardInfo(followCard: followCard).subscribe(onNext: { (result) in
                self.updateCardInfoSubject.onNext(result)
            }, onError: { (error) in
                self.updateCardInfoSubject.onError(error)
            }).disposed(by: self.disposeBag)
        }
    }
}
