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
enum CardFieldType: String {
    case name
    case id
}
protocol CardFirebaseInterface {
    ///創建卡稱
    func createCard(card: Card) -> Observable<FirebaseResult<Bool>>
    ///取得使用者卡稱資訊
    func setupCardData() -> Observable<FirebaseResult<Bool>>
    ///取得卡稱資訊
    func getCardInfo(uid: String) -> Observable<FirebaseResult<Card>>
    ///追蹤卡稱
    func insertFollowCard(followCard: FollowCard) -> Observable<FirebaseResult<Bool>>
    ///取得追蹤卡資訊
    func getfollowCardInfo() -> Observable<FirebaseResult<[FollowCard]>>
    ///取得卡片
    func getRandomCardBySex(cardMode: CardMode) -> Observable<FirebaseResult<[Card]>>
    ///修改卡稱資訊
    func updateCardInfo(card: [CardFieldType: Any]) -> Observable<FirebaseResult<Bool>>
    ///加入好友
     func addFriend(card: Card) -> Observable<FirebaseResult<Bool>>
}

class CardFirebase: CardFirebaseInterface {
    public static var shared = CardFirebase()
    private let disposeBag = DisposeBag()
    
    // MARK: - 創建卡稱
    func createCard(card: Card) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        
        let followCardListDir: [[String: [String: Any]]] = []

        let mood: [String: Any] = ["heart": card.mood.heart, "haha": card.mood.haha, "angry": card.mood.angry, "cry": card.mood.cry, "surprise": card.mood.surprise, "respect": card.mood.respect]
        let setter: [String: Any] = ["uid": card.uid, "id": card.id, "name": card.name, "photo": card.photo, "sex": card.sex, "introduce": card.introduce, "country": card.country, "school": card.school, "department": card.department, "article": card.article, "birthday": card.birthday, "love": card.love, "fans": card.fans, "followCard": followCardListDir, "beKeeped": card.beKeeped, "beReplyed": card.beReplyed, "getHeart": card.getHeart, "getMood": card.getMood, "mood": mood]
        
        FirebaseManager.shared.db.collection(DatabaseName.card.rawValue).document(ModelSingleton.shared.userConfig.user.uid).setData(setter) { (error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                ModelSingleton.shared.setUserCard(card)
                subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: nil))
            }
        }
        return subject.asObservable()
    }
    // MARK: - 取得卡稱資訊
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
    // MARK: - 取得使用者卡稱資訊
    func setupCardData() -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        
        FirebaseManager.shared.db.collection(DatabaseName.card.rawValue).document(ModelSingleton.shared.userConfig.user.uid).getDocument { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot, let dir = querySnapshot.data() {
                let moodDir = dir["mood"] as! [String: Any]
                let mood = Mood(heart: moodDir["heart"] as! Int, haha: moodDir["haha"] as! Int, angry: moodDir["angry"] as! Int, cry: moodDir["cry"] as! Int, surprise: moodDir["surprise"] as! Int, respect: moodDir["respect"] as! Int)
                let card = Card(uid: dir["uid"] as! String, id: dir["id"] as! String, name: dir["name"] as! String, photo: dir["photo"] as! String, sex: dir["sex"] as! String, introduce: dir["introduce"] as! String, country: dir["country"] as! String, school: dir["school"] as! String, department: dir["department"] as! String, article: dir["article"] as! String, birthday: dir["birthday"] as! String, love: dir["love"] as! String, fans: dir["fans"] as! Int, beKeeped: dir["beKeeped"] as! Int, beReplyed: dir["beReplyed"] as! Int, getHeart: dir["getHeart"] as! Int, mood: mood)
                ModelSingleton.shared.setUserCard(card)
                subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: nil))
            } else {
                subject.onNext(FirebaseResult<Bool>(data: false, errorMessage: .login(3), sender: nil))
            }
        }
        return subject
    }
    // MARK: - 追蹤卡稱
    func insertFollowCard(followCard: FollowCard) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        
        FirebaseManager.shared.db.collection(DatabaseName.card.rawValue).document(ModelSingleton.shared.userConfig.user.uid).getDocument { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                if let querySnapshot = querySnapshot, let dir = querySnapshot.data() {
                    var old = dir["followcard"] as! [String: [String: Any]]
                    old[followCard.card.uid] = ["uid": followCard.card.uid, "notifyMode": followCard.notifyMode, "isFollowing": followCard.isFollowing, "isNew": followCard.isNew]
                    FirebaseManager.shared.db.collection(DatabaseName.card.rawValue).document(ModelSingleton.shared.userConfig.user.uid).updateData(["followcard": old]) { (error) in
                        if let error = error {
                            NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                            subject.onError(error)
                        } else {
                            subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil))
                        }
                    }
                }
            }
        }
        return subject.asObservable()
    }
    // MARK: - 取得追蹤卡稱資訊
    func getfollowCardInfo() -> Observable<FirebaseResult<[FollowCard]>> {
        let subject = PublishSubject<FirebaseResult<[FollowCard]>>()
        var subjectList = [PublishSubject<Bool>]()
        var followCardList = [FollowCard]()
        
        FirebaseManager.shared.db.collection(DatabaseName.card.rawValue).document(ModelSingleton.shared.userConfig.user.uid).getDocument { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot, let dir = querySnapshot.data() {
                let followCardListDir = dir["followCard"] as! [String: [String: Any]]
                for _ in followCardList {
                    subjectList.append(PublishSubject<Bool>())
                }
                followCardListDir.keys.enumerated().forEach { (key, value) in
                    let dir = followCardListDir[value]!
                    self.getCardInfo(uid: dir["uid"] as! String).subscribe(onNext: { (result) in
                        subjectList[key].onNext(true)
                        followCardList.append(FollowCard(card: result.data, notifyMode: dir["notifyMode"] as! Int, isFollowing: dir["isFollowing"] as! Bool, isNew: dir["isNew"] as! Bool))
                    }).disposed(by: self.disposeBag)
                }
            }
        }
        Observable.combineLatest(subjectList).subscribe { (result) in
            let count: Int = result.element?.reduce(Int(0)) { (result, next) -> Int in
                return result + (next ? 1 : 0)
            } ?? 0
            if count == result.element?.count {
                subject.onNext(FirebaseResult<[FollowCard]>(data: followCardList, errorMessage: nil))
            } else {
                subject.onNext(FirebaseResult<[FollowCard]>(data: followCardList, errorMessage: BusinesslogicError.card(0)))
            }
        }.disposed(by: self.disposeBag)

        return subject.asObserver()
    }
    
    // MARK: - 取得卡片
    func getRandomCardBySex(cardMode: CardMode) -> Observable<FirebaseResult<[Card]>> {
        var subject = PublishSubject<FirebaseResult<[Card]>>()
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
                    subject.onNext(FirebaseResult<[Card]>(data: cards, errorMessage: nil, sender: nil))
                }
            }
        }
        return subject.asObserver()
    }
    private func getRandomCard() -> PublishSubject<FirebaseResult<[Card]>> {
        let subject = PublishSubject<FirebaseResult<[Card]>>()
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
                subject.onNext(FirebaseResult<[Card]>(data: cards, errorMessage: nil, sender: nil))
            }
        }
        return subject
    }
    // MARK: - 修改卡稱資訊
    func updateCardInfo(card: [CardFieldType: Any]) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        
        var setter: [String:Any] = [:]
        
        card.forEach { (key, value) in
            if key == .id || key == .name {
                setter["\(key.rawValue)"] = value as! String
            }
        }
        FirebaseManager.shared.db.collection(DatabaseName.card.rawValue).document(ModelSingleton.shared.userConfig.user.uid).updateData(setter) { (error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil))
                var oldCard = ModelSingleton.shared.userCard
                card.forEach { (key, value) in
                    switch key {
                    case .id:
                        oldCard.id = value as! String
                    case .name:
                        oldCard.name = value as! String
                    }
                }
                ModelSingleton.shared.setUserCard(oldCard)
            }
        }
        return subject.asObserver()
    }
    // MARK: - 加入好友
    func addFriend(card: Card) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        var cardId = ""
        var userId = ""
        var friendList = [String]()
        
        FirebaseManager.shared.db.collection(DatabaseName.card.rawValue).document(ModelSingleton.shared.userConfig.user.uid).getDocument { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot, let dir = querySnapshot.data() {
                var friend = dir["friend"] as! [String]
                friend.append(card.uid)
                var userCard = ModelSingleton.shared.userCard
                userCard.friendCard = friend
                ModelSingleton.shared.setUserCard(userCard)
                FirebaseManager.shared.db.collection(DatabaseName.card.rawValue).document(ModelSingleton.shared.userConfig.user.uid).updateData(["friend": friend]) { (error) in
                    if let error = error {
                        NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                        subject.onError(error)
                    }
                }
            }
        }
        return subject.asObserver()
    }
}
