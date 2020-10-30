//
//  cardFirebase.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/5.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase
import FirebaseFirestore
import FirebaseStorage

enum CardType {
    case success
    case error
}
protocol CardFirebaseInterface {
    func getRandomCardBySex(cardMode: CardMode) -> Observable<[Card]>
    func getCardInfo(uid: String) -> Observable<Card>
}

class CardFirebase: CardFirebaseInterface {
    public static var shared = CardFirebase()
    
    //取得卡稱資訊
    func getCardInfo(uid: String) -> Observable<Card> {
        let subject = PublishSubject<Card>()
        
        FirebaseManager.shared.db.collection(DatabaseName.card.rawValue).document(uid).getDocument { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            var cards = [Card]()
            if let querySnapshot = querySnapshot, let dir = querySnapshot.data() {
                
                let moodDir = dir["mood"] as! [String: Int]
                let mood = Mood(heart: moodDir["heart"], haha: moodDir["haha"], angry: moodDir["angry"], cry: moodDir["cry"], surprise: moodDir["surprise"], respect: moodDir["respect"])
                let card = Card(id: dir[""] as! String, name: dir[""] as! String, photo: dir[""] as! String, sex: dir[""] as! String, introduce: dir[""] as! String, country: dir[""] as! String, school: dir[""] as! String, department: dir[""] as! String, article: dir[""] as! String, birthday: dir[""] as! String, love: dir[""] as! String, fans: dir[""] as! Int, beKeeped: dir[""] as! Int, beReplyed: dir[""] as! Int, getHeart: dir[""] as! Int, mood: mood)
                subject.onNext(card)
                
                if uid == ModelSingleton.shared.userConfig.user.uid {
                    ModelSingleton.shared.setCard(card)
                }
            }
        }
        return subject.asObserver()
    }
    
    //取得卡片
    func getRandomCardBySex(cardMode: CardMode) -> Observable<[Card]> {
        var subject = PublishSubject<[Card]>()
        switch cardMode {
        case .all:
            subject = getRandomCard()
        default:
            FirebaseManager.shared.db.collection(DatabaseName.card.rawValue).getDocuments { (querySnapshot, error) in
                if let error = error {
                    NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                    subject.onError(error)
                }
                var cards = [Card]()
                if let querySnapshot = querySnapshot {
                    let querySnapshotBySex = querySnapshot.documents.filter { (queryDocumentSnapshot) -> Bool in
                        if let dir = queryDocumentSnapshot.data() as? [String:String] {
                            return dir["sex"] == cardMode.stringValue ? true : false
                        } else {
                            return false
                        }
                    }
                    var newQuerySnapshot = querySnapshotBySex
                    for _ in 1...3 {
                        let selectedItem = newQuerySnapshot.randomElement()
                        if let dir = selectedItem?.data() as? [String:String] {
                            cards.append(Card(name: dir["name"]!, photo: dir["photo"]!, sex: dir["sex"]!, introduce: dir["introduce"]!, country: dir["country"]!, school: dir["school"]!, article: dir["article"]!, birthday: dir["birthday"]!, love: dir["love"]!))
                        }
                        newQuerySnapshot = newQuerySnapshot.filter({ return $0 != selectedItem})
                    }
                    ModelSingleton.shared.setCard(cards)
                    subject.onNext(cards)
                }
            }
        }
        return subject.asObserver()
    }
    private func getRandomCard() -> PublishSubject<[Card]> {
        let subject = PublishSubject<[Card]>()
        FirebaseManager.shared.db.collection(DatabaseName.card.rawValue).getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            var cards = [Card]()
            if let querySnapshot = querySnapshot {
                var newQuerySnapshot = querySnapshot.documents
                for _ in 1...6 {
                    let selectedItem = newQuerySnapshot.randomElement()
                    if let dir = selectedItem?.data() as? [String:String] {
                        cards.append(Card(name: dir["name"]!, photo: dir["photo"]!, sex: dir["sex"]!, introduce: dir["introduce"]!, country: dir["country"]!, school: dir["school"]!, article: dir["article"]!, birthday: dir["birthday"]!, love: dir["love"]!))
                    }
                    newQuerySnapshot = newQuerySnapshot.filter({ return $0 != selectedItem})
                }
                ModelSingleton.shared.setCard(cards)
                subject.onNext(cards)
            }
        }
        return subject
    }
    
}
