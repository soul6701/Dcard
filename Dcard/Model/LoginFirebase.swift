//
//  Firebase.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/28.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase
import FirebaseFirestore
import FirebaseStorage

enum UserFieldType: String {
    case address
    case password
}
protocol LoginFirebaseInterface {
    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String, avatar: Data?) -> Observable<Bool>
    func login(address: String, password: String) -> Observable<FirebaseResult<Bool>>
    func setupCardData() -> Observable<FirebaseResult<Bool>>
    func setupFaroriteData() -> Observable<FirebaseResult<Bool>>
    func deleteUserData() -> Observable<DeleteCollectionType>
    func deletePostData() -> Observable<DeleteCollectionType>
    func expectAccount(address: String) -> Observable<FirebaseResult<Bool>>
    func requirePassword(uid: String, phone: String?, address: String?) -> Observable<FirebaseResult<Bool>>
    func getUserData(uid: String) -> Observable<FirebaseResult<User>>
    func addFriend(card: Card) -> Observable<FirebaseResult<Bool>>
    func updateUserInfo(user: [UserFieldType: Any]) -> Observable<FirebaseResult<Bool>>
}

public class LoginFirebase: LoginFirebaseInterface {

    enum Datatype {
        case user
        case post
        case favorite
        case comment
        case card
    }
    public static var shared = LoginFirebase()
    
    private var userConfig: UserConfig {
        return ModelSingleton.shared.userConfig
    }
    private var card: Card {
        return ModelSingleton.shared.userCard
    }
    private var post: [Post] {
        return ModelSingleton.shared.post
    }
    private var comment: [Comment] {
        return ModelSingleton.shared.comment
    }
    private var favorite: [Favorite] {
        return ModelSingleton.shared.favorite
    }
    private let disposeBag = DisposeBag()
    
    // MARK: - 創建帳戶
    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String, avatar: Data?) -> Observable<Bool> {
        
        let userSubject = PublishSubject<Bool>()
        let postSubject = PublishSubject<Bool>()
        let favoriteSubject = PublishSubject<Bool>()
        let commentSubject = PublishSubject<Bool>()
        let cardSubject = PublishSubject<Bool>()
        
        let subjectList: [Datatype: PublishSubject<Bool>] = [.user: userSubject, .post: postSubject, .favorite: favoriteSubject, .comment: commentSubject, .card: cardSubject]
        
        
        var avatarUrl = ""
        
        if let avatar = avatar {
            let ref = Storage.storage().reference().child(DatabaseName.user.rawValue).child(address + ".png")
            ref.putData(avatar, metadata: nil) { (metadata, error) in
                if let error = error {
                    NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                    userSubject.onError(error)
                } else {
                    userSubject.onNext(true)
                    ref.downloadURL { (url, error) in
                        if let error = error {
                            userSubject.onError(error)
                        }
                        if let url = url {
                            avatarUrl = url.absoluteString
                            self.addDocument(subject: subjectList, uid: "", firstName: firstName, lastName: lastName, birthday: birthday, sex: sex, phone: phone, address: address, password: password, avatarUrl: avatarUrl)
                        }
                    }
                }
            }
        } else {
            addDocument(subject: subjectList, uid: "", firstName: firstName, lastName: lastName, birthday: birthday, sex: sex, phone: phone, address: address, password: password, avatarUrl: avatarUrl)
        }
        
        return Observable.combineLatest(userSubject, postSubject, favoriteSubject, commentSubject, cardSubject).map { return $0 && $1 && $2 && $3 && $4 }
    }
    private func addDocument(subject: [Datatype: PublishSubject<Bool>], uid: String, firstName: String, lastName: String, birthday: String, sex: String, phone: String, address: String, password: String, avatarUrl: String) {
        
        let setter: [String: Any] = ["uid": uid, "firstname": firstName, "lastname": lastName, "birthday": birthday, "sex": sex, "phone": phone, "address": address, "password": password, "avatar": avatarUrl, "friend": [String](), "createAt": Date.getCurrentDateString(true)]
        let docID = FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).addDocument(data: setter) { (error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject[.user]?.onError(error)
            } else {
                subject[.user]?.onNext(true)
            }
        }
        docID.updateData(["uid" : docID.documentID])
        initData(databaseName: [DatabaseName.card.rawValue, DatabaseName.favoritePost.rawValue, DatabaseName.comment.rawValue, DatabaseName.post.rawValue], subject: subject, docID: docID)
    }
    private func initData(databaseName: [String], subject: [Datatype: PublishSubject<Bool>], docID: DocumentReference) {
        databaseName.forEach { (name) in
            let setterBlank: [String: Any] = [:]
            var _subject = PublishSubject<Bool>()
            switch name {
            case DatabaseName.card.rawValue:
                _subject = subject[.card]!
            case DatabaseName.favoritePost.rawValue:
                _subject = subject[.favorite]!
            case DatabaseName.comment.rawValue:
                _subject = subject[.comment]!
            case DatabaseName.post.rawValue:
                _subject = subject[.post]!
            default:
                break
            }
            FirebaseManager.shared.db.collection(name).document(docID.documentID).setData(setterBlank) { (error) in
                if let error = error {
                    NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                    _subject.onError(error)
                } else {
                    _subject.onNext(true)
                }
            }
        }
    }
    // MARK: - 檢查帳號是否重複
    func expectAccount(address: String) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot {
                if !(querySnapshot.documents.filter { (queryDocumentSnapshot) -> Bool in
                    let dir = queryDocumentSnapshot.data()
                    return (dir["address"] as! String) == address ? true : false
                }.isEmpty) {
                    subject.onNext(FirebaseResult<Bool>(data: false, errorMessage: nil, sender: nil))
                } else {
                    subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: nil))
                }
            }
        }
        return subject.asObserver()
    }
    
    // MARK: - 刪除所有使用者資料
    func deleteUserData() -> Observable<DeleteCollectionType> {
        return FirebaseManager.shared.deleteCollection(FirebaseManager.shared.db, DatabaseName.user.rawValue)
    }
    // MARK: - 刪除所有貼文資料
    func deletePostData() -> Observable<DeleteCollectionType> {
        return FirebaseManager.shared.deleteCollection(FirebaseManager.shared.db, DatabaseName.allPost.rawValue)
    }
    // MARK: - 登入
    func login(address: String, password: String) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        
        FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
                if !(querySnapshot.documents.filter { (queryDocumentSnapshot) -> Bool in
                    let dir = queryDocumentSnapshot.data()
                    if dir["address"] as! String == address && dir["password"] as! String == password {
                        let userConfig = UserConfig(user: User(uid: dir["uid"] as! String, lastName: dir["lastname"] as! String, firstName: dir["firstname"] as! String, birthday: dir["birthday"] as! String, sex: dir["sex"] as! String, phone: dir["phone"] as! String, address: dir["address"] as! String, password: dir["password"] as! String, avatar: dir["avatar"] as! String, friend: dir["friend"] as! [String]), cardmode: 0)
                        ModelSingleton.shared.setUserConfig(userConfig)
                        return true
                    }
                    return false
                }.isEmpty) {
                    subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil))
                } else if !(querySnapshot.documents.filter { (queryDocumentSnapshot) -> Bool in
                    let dir = queryDocumentSnapshot.data()
                    if (dir["address"] as! String) == address {
                        return true
                    }
                    return false
                }.isEmpty) {
                    subject.onNext(FirebaseResult<Bool>(data: false, errorMessage: .login(1), sender: nil))
                } else {
                    subject.onNext(FirebaseResult<Bool>(data: false, errorMessage: .login(0), sender: nil))
                }
            } else {
                subject.onNext(FirebaseResult<Bool>(data: false, errorMessage: .login(0), sender: nil))
            }
        }
        return subject.asObserver()
    }
    // MARK: - 取得卡稱資訊
    func setupCardData() -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        
        FirebaseManager.shared.db.collection(DatabaseName.card.rawValue).document(self.userConfig.user.uid).getDocument { (querySnapshot, error) in
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
    // MARK: - 取得收藏清單
    func setupFaroriteData() -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        var favoriteList = [Favorite]()
        FirebaseManager.shared.db.collection(DatabaseName.favoritePost.rawValue).document(self.userConfig.user.uid).getDocument { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
            }
            if let querySnapshot = querySnapshot, let dir = querySnapshot.data() {
                let favoriteArray = dir["favorite"] as! Array<[String: Any]>
                favoriteArray.forEach { (favoriteDir) in
                    let title = favoriteDir["title"] as! String
                    let createAt = favoriteDir["createAt"] as! String
                    let postIDList = favoriteDir["post"] as! [String]
                    favoriteList.append(Favorite(title: title, createAt: createAt, postIDList: postIDList))
                }
                ModelSingleton.shared.setFavoriteList(favoriteList)
                subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: nil))
            } else {
                subject.onNext(FirebaseResult<Bool>(data: false, errorMessage: .login(4), sender: nil))
            }
        }
        return subject
    }
    // MARK: - 查詢密碼
    func requirePassword(uid: String, phone: String?, address: String?) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        var successString = ""
        
        FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
                    if !(querySnapshot.documents.filter { (queryDocumentSnapshot) -> Bool in
                        let dir = queryDocumentSnapshot.data()
                        if let phone = phone {
                            let _phone = "886-" + phone
                            if (dir["uid"] as! String) == uid && (dir["phone"] as! String) == _phone {
                                successString = dir["password"] as! String
                                return true
                            }
                        }
                        if let address = address {
                            if (dir["uid"] as! String) == uid && (dir["address"] as! String) == address {
                                successString = dir["password"] as! String
                                return true
                            }
                        }
                        return false
                    }.isEmpty) {
                        subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: ["password": successString]))
                    } else if !(querySnapshot.documents.filter { (queryDocumentSnapshot) -> Bool in
                        let dir = queryDocumentSnapshot.data()
                        if (dir["uid"] as! String) == uid {
                            return true
                        }
                        return false
                    }.isEmpty) {
                        subject.onNext(FirebaseResult<Bool>(data: false, errorMessage: .login(2), sender: nil))
                    } else {
                        subject.onNext(FirebaseResult<Bool>(data: false, errorMessage: .login(0), sender: nil))
                    }
                } else {
                    subject.onNext(FirebaseResult<Bool>(data: false, errorMessage: .login(0), sender: nil))
                }
            }
        }
        return subject.asObserver()
    }
    
    // MARK: - 取得使用者資訊
    func getUserData(uid: String) -> Observable<FirebaseResult<User>> {
        let subject = PublishSubject<FirebaseResult<User>>()
        
        FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).document(ModelSingleton.shared.userConfig.user.uid).getDocument { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot, let dir = querySnapshot.data() {
                subject.onNext(FirebaseResult<User>(data: User(uid: dir["uid"] as! String, lastName: dir["lastname"] as! String, firstName: dir["firstname"] as! String, birthday: dir["birthday"] as! String, sex: dir["sex"] as! String, phone: dir["phone"] as! String, address: dir["address"] as! String, password: dir["password"] as! String, avatar: dir["avatar"] as! String, friend: dir["friend"] as! [String]), errorMessage: nil, sender: nil))
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
        
    // MARK: - 修改使用者資訊
    func updateUserInfo(user: [UserFieldType : Any]) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        
        var setter: [String:Any] = [:]
        
        user.forEach { (key, value) in
            if key == .password || key == .address {
                setter["\(key.rawValue)"] = value as! String
            }
        }
        FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).document(ModelSingleton.shared.userConfig.user.uid).updateData(setter) { (error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: nil))
                var oldUser = self.userConfig.user
                user.forEach { (key, value) in
                    switch key {
                    case .address:
                        oldUser.address = value as! String
                    case .password:
                        oldUser.password = value as! String
                    }
                }
                ModelSingleton.shared.setUserConfig(UserConfig(user: oldUser, cardmode: self.userConfig.cardmode))
            }
        }
        return subject.asObserver()
    }
    
}
