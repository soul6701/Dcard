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
    func deleteUserData() -> Observable<DeleteCollectionType>
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
        
        return Observable.combineLatest(userSubject, postSubject, postSubject, commentSubject).map { return $0 && $1 && $2 && $3 }
    }
    private func addDocument(subject: [Datatype: PublishSubject<Bool>], uid: String, firstName: String, lastName: String, birthday: String, sex: String, phone: String, address: String, password: String, avatarUrl: String) {
        var commentList: [[String: Any]] = []
        self.comment.forEach { (comment) in
            var mediaMetaList: [[String: Any]] = []
            comment.mediaMeta.forEach { (mediaMeta) in
                mediaMetaList.append(["ormalizedUrl,": mediaMeta.normalizedUrl, "thumbnail": mediaMeta.thumbnail])
            }
            commentList.append(["id": comment.id, "anonymous": comment.anonymous, "content": comment.content, "createdAt": comment.createdAt, "floor": comment.floor, "likeCount": comment.likeCount, "gender": comment.gender, "department": comment.department, "school": comment.school, "withNickname": comment.withNickname, "host": comment.host, "mediaMeta": mediaMetaList])
        }
        var favariteList: [[String: Any]] = []
        self.favorite.forEach { (favorite) in
            var postList: [[String: Any]] = []
            favorite.posts.forEach { (post) in
                var mediaMetaList: [[String: Any]] = []
                post.mediaMeta.forEach { (mediaMeta) in
                    mediaMetaList.append(["ormalizedUrl,": mediaMeta.normalizedUrl, "thumbnail": mediaMeta.thumbnail])
                }
                postList.append(["id": post.id, "title": post.title, "excerpt": post.excerpt, "createdAt": post.createdAt, "commentCount": post.commentCount, "likeCount": post.likeCount, "forumName": post.forumName, "gender": post.gender, "department": post.department, "anonymousSchool": post.anonymousSchool, "anonymousDepartment": post.anonymousDepartment, "school": post.school, "withNickname": post.withNickname, "mediaMeta": mediaMetaList, "host": post.host, "hot": post.hot])
            }
            favariteList.append(["title": favorite.title, "posts": postList])
        }
        
        let setterFavoritePost: [String: Any] = ["uid": uid, "firstname": firstName, "lastname": lastName, "birthday": birthday, "sex": sex, "phone": phone, "address": address, "password": password, "avatar": avatarUrl, "friend": [String](), "createAt": FieldValue.serverTimestamp()]
        let docID = FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).addDocument(data: setterFavoritePost) { (error) in
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
                        self.setupCardData(uid: dir["uid"] as! String)
                        self.setupUserConfigData(dir: dir)
                        self.setupFaroriteData(docID: dir["uid"] as! String, subject: subject)
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
                    subject.onNext(FirebaseResult<Bool>(data: false, errorMessage: .login(1)))
                } else {
                    subject.onNext(FirebaseResult<Bool>(data: false, errorMessage: .login(0)))
                }
            } else {
                subject.onNext(FirebaseResult<Bool>(data: false, errorMessage: .login(0)))
            }
        }
        return subject.asObserver()
    }
    private func setupFaroriteData(docID: String, subject: PublishSubject<FirebaseResult<Bool>>) {
        FirebaseManager.shared.db.collection(DatabaseName.favoritePost.rawValue).document(docID).getDocument { (documentSnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let documentSnapshot = documentSnapshot, let dir = documentSnapshot.data() {
                var favoriteList = [Favorite]()
                let favoriteArray = dir["favorite"] as! [[String: Any]]
                favoriteArray.forEach { (dir) in
                    var postList = [Post]()
                    let postArray = dir["post"] as! [[String: Any]]
                    postArray.forEach { (dir) in
                        var mediaMetaList = [MediaMeta]()
                        let mediaMetaArray = dir["mediaMeta"] as! [[String: Any]]
                        mediaMetaArray.forEach { (dir) in
                            let _dir = dir as! [String: String]
                            mediaMetaList.append(MediaMeta(thumbnail: _dir["thumbnail"]!, normalizedUrl: _dir["normalizedUrl"]!))
                        }
                        postList.append(Post(id: dir["id"] as! String, title: dir["title"] as! String, excerpt: dir["excerpt"] as! String, createdAt: dir["createdAt"] as! String, commentCount: dir["commentCount"] as! String, likeCount: dir["likeCount"] as! String, forumName: dir["forumName"] as! String, gender: dir["gender"] as! String, department: dir["department"] as! String, anonymousSchool: dir[""] as! Bool, anonymousDepartment: dir["anonymousDepartment"] as! Bool, school: dir["school"] as! String, withNickname: dir["withNickname"] as! Bool, mediaMeta: mediaMetaList, host: dir["host"] as! Bool, hot: dir["hot"] as! Bool))
                    }
                    favoriteList.append(Favorite(title: dir["title"] as! String, posts: postList))
                }
                ModelSingleton.shared.setFavoriteList(favoriteList)
            }
        }
    }
    private func setupCardData(uid: String) {
        FirebaseManager.shared.db.collection(DatabaseName.card.rawValue).document(uid).getDocument { (querySnapshot, error) in
            if let querySnapshot = querySnapshot, let dir = querySnapshot.data() {
                let mood = Mood(heart: dir["heart"] as! Int, haha: dir["haha"] as! Int, angry: dir["angry"] as! Int, cry: dir["cry"] as! Int, surprise: dir["surprise"] as! Int, respect: dir["respect"] as! Int)
                let card = Card(id: dir["id"] as! String, name: dir["name"] as! String, photo: dir["photo"] as! String, sex: dir["sex"] as! String, introduce: dir["introduce"] as! String, country: dir["country"] as! String, school: dir["school"] as! String, department: dir["department"] as! String, article: dir["article"] as! String, birthday: dir["birthday"] as! String, love: dir["love"] as! String, fans: dir["fans"] as! Int, beKeeped: dir["beKeeped"] as! Int, beReplyed: dir["beReplyed"] as! Int, getHeart: dir["getHeart"] as! Int, mood: mood)
                ModelSingleton.shared.setUserCard(card)
            }
        }
    }
    private func setupUserConfigData(dir: [String: Any]) {
        let userConfig = UserConfig(user: User(uid: dir["uid"] as! String, lastName: dir["lastname"] as! String, firstName: dir["firstname"] as! String, birthday: dir["birthday"] as! String, sex: dir["sex"] as! String, phone: dir["phone"] as! String, address: dir["address"] as! String, password: dir["password"] as! String, avatar: dir["avatar"] as! String, friend: dir["friend"] as! [String]), cardmode: 0)
        ModelSingleton.shared.setUserConfig(userConfig)
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
