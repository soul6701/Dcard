//
//  PostFirebase.swift
//  Dcard
//
//  Created by Mason on 2020/10/29.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase
import FirebaseFirestore
import FirebaseStorage

protocol PostFirebaseInterface {
    func creartFavoriteList(listName: String, post: Post) -> Observable<Bool>

}

public class PostFirebase: PostFirebaseInterface {

    public static var shared = PostFirebase()

    private var user: User {
        return ModelSingleton.shared.userConfig.user
    }

    // MARK: - 創建播放清單
    func creartFavoriteList(listName: String, post: Post) -> Observable<Bool> {
        let subject = PublishSubject<Bool>()
        var mediaMetaList: [[String: Any]] = []
        post.mediaMeta.forEach { (mediaMeta) in
            mediaMetaList.append(["normalizedUrl": mediaMeta.normalizedUrl, "thumbnail": mediaMeta.thumbnail])
        }
        let post: [String: Any] = ["id": post.id, "title": post.title, "excerpt": post.excerpt, "createdAt": post.createdAt, "commentCount": post.commentCount, "likeCount": post.likeCount, "forumName": post.forumName, "gender": post.gender, "department": post.department, "anonymousSchool": post.anonymousSchool, "anonymousDepartment": post.anonymousDepartment, "school": post.school, "withNickname": post.withNickname, "mediaMeta": mediaMetaList, "host": post.host, "hot": post.hot]
        let setter = ["Post": [post]]
        FirebaseManager.shared.db.collection(DatabaseName.favoritePost.rawValue).document("\(user.uid)").setData(setter) { (error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                subject.onNext(true)
            }
        }
        return subject.asObserver()
    }
    
    // MARK: - 檢查帳號是否重複
    func expectAccount(address: String) -> Observable<Bool> {
        let subject = PublishSubject<Bool>()
        FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                if let querySnapshot = querySnapshot {
                    if !(querySnapshot.documents.filter { (queryDocumentSnapshot) -> Bool in
                        let dir = queryDocumentSnapshot.data()
                        return (dir["address"] as! String) == address ? true : false
                    }.isEmpty) {
                        subject.onNext(false)
                    } else {
                        subject.onNext(true)
                    }
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
    func login(address: String, password: String) -> Observable<LoginType> {
        let subject = PublishSubject<LoginType>()

        FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
                if !(querySnapshot.documents.filter { (queryDocumentSnapshot) -> Bool in
                    let dir = queryDocumentSnapshot.data()
                    if dir["address"] as! String == address && dir["password"] as! String == password {
                        ModelSingleton.shared.setUserConfig(UserConfig(user: User(uid: dir["uid"] as! String, lastName: dir["lastname"] as! String, firstName: dir["firstname"] as! String, birthday: dir["birthday"] as! String, sex: dir["sex"] as! String, phone: dir["phone"] as! String, address: dir["address"] as! String, password: dir["password"] as! String, avatar: dir["avatar"] as! String, friend: dir["friend"] as! [String]), cardmode: 0))
                        return true
                    }
                    return false
                }.isEmpty) {
                    subject.onNext(.success)
                } else if !(querySnapshot.documents.filter { (queryDocumentSnapshot) -> Bool in
                    let dir = queryDocumentSnapshot.data()
                    if (dir["address"] as! String) == address {
                        return true
                    }
                    return false
                }.isEmpty) {
                    subject.onNext(.error(.password))
                } else {
                    subject.onNext(.error(.account))
                }
            } else {
                subject.onNext(.error(.account))
            }
        }
        return subject.asObserver()
    }

    // MARK: - 查詢密碼
    func requirePassword(uid: String, phone: String?, address: String?) -> Observable<RequirePasswordType> {
        let subject = PublishSubject<RequirePasswordType>()
        var successString = ""

        FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
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
                    subject.onNext(.success(successString))
                } else if !(querySnapshot.documents.filter { (queryDocumentSnapshot) -> Bool in
                    let dir = queryDocumentSnapshot.data()
                    if (dir["uid"] as! String) == uid {
                        return true
                    }
                    return false
                }.isEmpty) {
                    subject.onNext(.error(.phone))
                } else {
                    subject.onNext(.error(.account))
                }
            } else {
                subject.onNext(.error(.account))
            }
        }
        return subject.asObserver()
    }

    // MARK: - 取得使用者資訊
    func getUserData(uid: String) -> Observable<User> {
        let subject = PublishSubject<User>()

        FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot {
                let document = querySnapshot.documents.first { (queryDocumentSnapshot) -> Bool in
                    let dir = queryDocumentSnapshot.data()
                    return (dir["uid"] as! String) == uid
                }
                if let document = document {
                    let user = document.data()
                    subject.onNext(User(uid: user["uid"] as! String, lastName: user["lastname"] as! String, firstName: user["firstname"] as! String, birthday: user["birthday"] as! String, sex: user["sex"] as! String, phone: user["phone"] as! String, address: user["address"] as! String, password: user["password"] as! String, avatar: user["avatar"] as! String, friend: user["friend"] as! [String]))
                }
            }
        }
        return subject.asObserver()
    }

    // MARK: - 加入好友
    func addFriend(name: String) -> Observable<Bool> {
        let subject = PublishSubject<Bool>()
        var cardId = ""
        var userId = ""
        var friendList = [String]()

        FirebaseManager.shared.db.collection(DatabaseName.card.rawValue).getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot {
                let document = querySnapshot.documents.first { (queryDocumentSnapshot) -> Bool in
                    let dir = queryDocumentSnapshot.data()
                    return (dir["name"] as! String) == name
                }
                cardId = document?.documentID ?? ""
            }
            guard !cardId.isEmpty else {
                subject.onNext(false)
                return
            }
            FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).getDocuments { (querySnapshot, error) in
                if let error = error {
                    NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                    subject.onError(error)
                }
                if let querySnapshot = querySnapshot {
                    let document = querySnapshot.documents.first { (queryDocumentSnapshot) -> Bool in
                        let dir = queryDocumentSnapshot.data()
                        return (dir["uid"] as! String) == ModelSingleton.shared.userConfig.user.uid
                    }
                    userId = document?.documentID ?? ""
                    if let dir = document?.data() {
                        friendList = dir["friend"] as! [String]
                        friendList.append(cardId)
                    }
                }
                guard !userId.isEmpty else {
                    subject.onNext(false)
                    return
                }
                FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).document(userId).updateData(["friend" : friendList]) { (error) in
                    if let error = error {
                        NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                        subject.onError(error)
                    } else {
                        subject.onNext(true)
                        var (oldUser, oldCardMode) = (ModelSingleton.shared.userConfig.user, ModelSingleton.shared.userConfig.cardmode)
                        oldUser.friend = friendList
                        ModelSingleton.shared.setUserConfig(UserConfig(user: oldUser, cardmode: oldCardMode))
                    }
                }
            }
        }
        return subject.asObserver()
    }
//    // MARK: - 修改使用者資訊
//    func updateUserInfo(newAddress: String, newPassword: String, newCard: [CardFieldType: Any]) -> Observable<Bool> {
//        let subject = PublishSubject<Bool>()
//        var userId = ""
//
//        FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).getDocuments { (querySnapshot, error) in
//            if let error = error {
//                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
//                subject.onError(error)
//            }
//            if let querySnapshot = querySnapshot {
//                let document = querySnapshot.documents.first { (queryDocumentSnapshot) -> Bool in
//                    let dir = queryDocumentSnapshot.data()
//                    return (dir["uid"] as! String) == ModelSingleton.shared.userConfig.user.uid
//                }
//                userId = document?.documentID ?? ""
//            }
//            guard !userId.isEmpty else {
//                subject.onNext(false)
//                return
//            }
//            var setter: [String:Any] = [:]
//
//            if !newAddress.isEmpty {
//                setter["address"] = newAddress
//            } else if !newPassword.isEmpty {
//                setter["password"] = newPassword
//            } else if !newCard.isEmpty {
//                newCard.forEach { (key, value) in
//                    if key == .id || key == .name {
//                        setter["card.\(key.rawValue)"] = value
//                    }
//                }
//            }
//            guard !setter.isEmpty else {
//                subject.onNext(false)
//                return
//            }
//            FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).document(userId).updateData(setter) { (error) in
//                if let error = error {
//                    NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
//                    subject.onError(error)
//                } else {
//                    subject.onNext(true)
//
//                    var oldUser = self.userConfig.user
//                    var oldCard = self.card
//                    if !newAddress.isEmpty {
//                        oldUser.address = newAddress
//                    } else if !newPassword.isEmpty {
//                        oldUser.password = newPassword
//                    } else if !newCard.isEmpty {
//                        newCard.forEach { (key, value) in
//                            switch key {
//                            case .id:
//                                oldCard.id = value as! String
//                            case .name:
//                                oldCard.name = value as! String
//                            }
//                        }
//                    }
//                     ModelSingleton.shared.setUserCard(oldCard)
//                    ModelSingleton.shared.setUserConfig(UserConfig(user: oldUser, cardmode: self.userConfig.cardmode))
//                }
//            }
//        }
//        return subject.asObserver()
//    }
}
