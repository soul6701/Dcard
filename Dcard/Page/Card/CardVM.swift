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
    var getRandomCardBySexSubject: PublishSubject<FirebaseResult<[Card]>> { get }
    
    ///加入好友
    func addFriend(card: Card)
    var addFriendSubject: PublishSubject<FirebaseResult<Bool>> { get }
    
    ///創建卡稱
    func createCard(card: Card)
    var createCardSubject: PublishSubject<FirebaseResult<Bool>> { get }
    
    ///取得卡稱資訊
    func getCardInfo(uid: String)
    var getCardInfoSubject: PublishSubject<FirebaseResult<Card>> { get }
    
    ///取得追蹤卡稱資訊
    func getfollowCardInfo()
    var getfollowCardInfoSubject: PublishSubject<FirebaseResult<[FollowCard]>> { get }
    
    ///修改卡稱資訊
    func updateCardInfo(card: [CardFieldType: Any])
    var updateCardInfoSubject : PublishSubject<FirebaseResult<Bool>> { get }
}
class CardVM: CardVMInterface {
    
    private(set) var getRandomCardBySexSubject = PublishSubject<FirebaseResult<[Card]>>()
    private(set) var addFriendSubject = PublishSubject<FirebaseResult<Bool>>()
    private(set) var createCardSubject = PublishSubject<FirebaseResult<Bool>>()
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
    
    func createCard(card: Card) {
        self.cardFirebase.createCard(card: card).subscribe(onNext: { (result) in
            self.createCardSubject.onNext(result)
        }, onError: { (error) in
            self.createCardSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func getRandomCardBySex(cardMode: CardMode) {
        self.cardFirebase.getRandomCardBySex(cardMode: cardMode).subscribe(onNext: { (result) in
            self.getRandomCardBySexSubject.onNext(result)
        }, onError: { (error) in
            self.getRandomCardBySexSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func addFriend(card: Card) {
        self.cardFirebase.addFriend(card: card).subscribe(onNext: { (result) in
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
    func updateCardInfo(card: [CardFieldType: Any]) {
        self.cardFirebase.updateCardInfo(card: card).subscribe(onNext: { (result) in
            self.updateCardInfoSubject.onNext(result)
        }, onError: { (error) in
            self.updateCardInfoSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
}
