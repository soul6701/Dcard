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
    //取得卡片
    var getRandomCardBySexSubject: PublishSubject<[Card]> { get }
    func getRandomCardBySex(cardMode: CardMode)
    //加入好友
    var addFriendSubject: PublishSubject<Bool> { get }
    func addFriend(name: String)
    //取得卡稱資訊
    var getCardInfoSubject: PublishSubject<Card> { get }
    func getCardInfo(uid: String)
}
class CardVM: CardVMInterface {
    private(set) var getRandomCardBySexSubject = PublishSubject<[Card]>()
    private(set) var addFriendSubject = PublishSubject<Bool>()
    private(set) var getCardInfoSubject = PublishSubject<Card>()
    
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
        self.cardFirebase.getRandomCardBySex(cardMode: cardMode).subscribe(onNext: { (cards) in
            self.getRandomCardBySexSubject.onNext(cards)
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
        self.cardFirebase.getCardInfo(uid: uid).subscribe(onNext: { (card) in
            self.getCardInfoSubject.onNext(card)
        }, onError: { (error) in
            self.getCardInfoSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
}
