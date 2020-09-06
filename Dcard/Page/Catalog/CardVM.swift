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
}
class CardVM: CardVMInterface {
    private (set) var getRandomCardBySexSubject = PublishSubject<[Card]>()
    
    private var cardFirebase: CardFirebaseInterface
    private var disposeBag = DisposeBag()
    
    init(cardFirebase: CardFirebaseInterface = CardFirebase.shared) {
        self.cardFirebase = cardFirebase
    }
}
extension CardVM {
    
    func getRandomCardBySex(cardMode: CardMode) {
        cardFirebase.getRandomCardBySex(cardMode: cardMode).subscribe(onNext: { (cards) in
            self.getRandomCardBySexSubject.onNext(cards)
        }, onError: { (error) in
            self.getRandomCardBySexSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
}
