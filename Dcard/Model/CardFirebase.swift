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
    func getCardInfo(uid: String) -> Observable<FirebaseResult<Card>>
    func createCard(card: Card) -> Observable<Bool>
    func getfollowCardInfo() -> Observable<FirebaseResult<[FollowCard]>>
    func updateCardInfo(followCard: FollowCard) -> Observable<FirebaseResult<Bool>>
}

class CardFirebase: CardFirebaseInterface {
    public static var shared = CardFirebase()
    
    // MARK: - 創建卡稱
    func createCard(card: Card) -> Observable<Bool> {
        let subject = PublishSubject<Bool>()
        
        var followCardListDir: [[String: [String: Any]]] = []
        
        card.followCard.forEach { (followCard) in
            followCardListDir.append([followCard.uid : ["uid": followCard.uid, "notifyMode": followCard.notifyMode, "isFollowing": followCard.isFollowing, "notifyMode": followCard.notifyMode]])
        }
        let mood: [String: Any] = ["heart": card.mood.heart, "haha": card.mood.haha, "angry": card.mood.angry, "cry": card.mood.cry, "surprise": card.mood.surprise, "respect": card.mood.respect]
        let setter: [String: Any] = ["id": card.id, "name": card.name, "photo": card.photo, "sex": card.sex, "introduce": card.introduce, "country": card.country, "school": card.school, "department": card.department, "article": card.article, "birthday": card.birthday, "love": card.love, "fans": card.fans, "followCard": followCardListDir, "beKeeped": card.beKeeped, "beReplyed": card.beReplyed, "getHeart": card.getHeart, "getMood": card.getMood, "mood": mood]
        
        FirebaseManager.shared.db.collection(DatabaseName.card.rawValue).document(ModelSingleton.shared.userConfig.user.uid).setData(setter) { (error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                subject.onNext(true)
            }
        }
        return subject.asObservable()
    }
    // MARK: - 取得單一卡稱資訊
    func getCardInfo(uid: String) -> Observable<FirebaseResult<Card>> {
        let subject = PublishSubject<FirebaseResult<Card>>()
        
        FirebaseManager.shared.db.collection(DatabaseName.card.rawValue).document(uid).getDocument { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot, let dir = querySnapshot.data() {
                
                let moodDir = dir["mood"] as! [String: Int]
                let mood = Mood(heart: moodDir["heart"]!, haha: moodDir["haha"]!, angry: moodDir["angry"]!, cry: moodDir["cry"]!, surprise: moodDir["surprise"]!, respect: moodDir["respect"]!)
                let card = Card(id: dir[""] as! String, name: dir[""] as! String, photo: dir[""] as! String, sex: dir[""] as! String, introduce: dir[""] as! String, country: dir[""] as! String, school: dir[""] as! String, department: dir[""] as! String, article: dir[""] as! String, birthday: dir[""] as! String, love: dir[""] as! String, fans: dir[""] as! Int, beKeeped: dir[""] as! Int, beReplyed: dir[""] as! Int, getHeart: dir[""] as! Int, mood: mood)
                subject.onNext(FirebaseResult<Card>(data: card, errorMessage: nil))
                
                if uid == ModelSingleton.shared.userConfig.user.uid {
                    ModelSingleton.shared.setUserCard(card)
                }
            } else {
                if uid == ModelSingleton.shared.userConfig.user.uid {
                    subject.onNext(FirebaseResult<Card>(data: ModelSingleton.shared.userCard, errorMessage: .card(0)))
                }
            }
        }
        return subject.asObserver()
    }
    // MARK: - 取得追蹤卡稱資訊
    func getfollowCardInfo() -> Observable<FirebaseResult<[FollowCard]>> {
        let subject = PublishSubject<FirebaseResult<[FollowCard]>>()
        
        FirebaseManager.shared.db.collection(DatabaseName.card.rawValue).document(ModelSingleton.shared.userConfig.user.uid).getDocument { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot, let dir = querySnapshot.data() {
                var followCardList = [FollowCard]()
                let followCardListDir = dir["followCard"] as! [[String: Any]]
                followCardListDir.forEach { (followCardDir) in
                    followCardList.append(FollowCard(uid: followCardDir["uid"] as! String, notifyMode: followCardDir["notifyMode"] as! Int, isFollowing: followCardDir["isFollowing"] as! Bool, isNew: followCardDir["isNew"] as! Bool))
                }
                subject.onNext(FirebaseResult<[FollowCard]>(data: followCardList, errorMessage: nil))
            }
        }
        return subject.asObserver()
    }
    
    // MARK: - 取得卡片
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
    // MARK: - 修改卡稱資訊
    func updateCardInfo(followCard: FollowCard) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        
        let followCardDir: [String: Any] = ["uid": followCard.uid,  "notifyMode": followCard.notifyMode, "isFollowing": followCard.isFollowing, "isNew": followCard.isNew]
        let setter: [String: Any] = ["followCard.\(followCard.uid)": followCardDir]
        FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).document(ModelSingleton.shared.userConfig.user.uid).updateData(setter) { (error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                var oldCard = ModelSingleton.shared.userCard
                oldCard.followCard.removeAll { $0.uid == followCard.uid }
                ModelSingleton.shared.setUserCard(oldCard)
            }
        }
        return subject.asObserver()
    }
}
