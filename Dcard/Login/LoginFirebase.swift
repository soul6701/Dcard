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

enum LoginType {
    case success
    case error(LoginErroType)
}
enum LoginErroType: String {
    case account = "找不到此用戶"
    case password = "密碼錯誤"
    case phone = "信箱/手機錯誤"
}
enum RequirePasswordType {
    case success(String)
    case error(LoginErroType)
}
protocol LoginFirebaseInterface {
    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String, avatar: Data?) -> Observable<Bool>
    func login(lastName: String, firstName: String, password: String) -> Observable<LoginType>
    func deleteUserData() -> Observable<DeleteCollectionType>
    func expectAccount(lastName: String, firstName: String) -> Observable<Bool>
    func requirePassword(uid: String, phone: String?, address: String?) -> Observable<RequirePasswordType>
    func getUserData(uid: String) -> Observable<User>
    func addFriend(name: String) -> Observable<Bool>
    func resetAddressPassword(newAddress: String, newPassword: String) -> Observable<Bool>
}

public class LoginFirebase: LoginFirebaseInterface {
    
    public static var shared = LoginFirebase()
    
    // MARK: - 創建帳戶
    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String, avatar: Data?) -> Observable<Bool> {
        let subject = PublishSubject<Bool>()
        let uid = "\(lastName)_\(firstName)"
        var avatarUrl = ""
        
        if let avatar = avatar {
            let ref = Storage.storage().reference().child(DatabaseName.user.rawValue).child(uid + ".png")
            ref.putData(avatar, metadata: nil) { (metadata, error) in
                if let error = error {
                    NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                    subject.onError(error)
                } else {
                    subject.onNext(true)
                    ref.downloadURL { (url, error) in
                        if let error = error {
                            subject.onError(error)
                        }
                        if let url = url {
                            avatarUrl = url.absoluteString
                            self.addDocument(subject: subject, uid: uid, firstName: firstName, lastName: lastName, birthday: birthday, sex: sex, phone: phone, address: address, password: password, avatarUrl: avatarUrl)
                        }
                    }
                }
            }
        } else {
            addDocument(subject: subject, uid: uid, firstName: firstName, lastName: lastName, birthday: birthday, sex: sex, phone: phone, address: address, password: password, avatarUrl: avatarUrl)
        }
        
        return subject.asObserver()
    }
    private func addDocument(subject: PublishSubject<Bool>, uid: String, firstName: String, lastName: String, birthday: String, sex: String, phone: String, address: String, password: String, avatarUrl: String) {
        FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).addDocument(data: ["uid": uid, "firstname": firstName, "lastname": lastName, "birthday": birthday, "sex": sex, "phone": phone, "address": address, "password": password, "avatar": avatarUrl, "friend": [String]()]) { (error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                subject.onNext(true)
            }
        }
    }
    // MARK: - 檢查帳號是否重複
    func expectAccount(lastName: String, firstName: String) -> Observable<Bool> {
        let subject = PublishSubject<Bool>()
        let uid = lastName + "_" + firstName
        FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot {
                if !(querySnapshot.documents.filter { (queryDocumentSnapshot) -> Bool in
                    let dir = queryDocumentSnapshot.data()
                    return (dir["uid"] as! String) == uid ? true : false
                }.isEmpty) {
                    subject.onNext(false)
                } else {
                    subject.onNext(true)
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
    func login(lastName: String, firstName: String, password: String) -> Observable<LoginType> {
        let subject = PublishSubject<LoginType>()
        
        FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
                if !(querySnapshot.documents.filter { (queryDocumentSnapshot) -> Bool in
                    let dir = queryDocumentSnapshot.data()
                    if dir["uid"] as! String == "\(lastName)_\(firstName)" && dir["password"] as! String == password {
                        ModelSingleton.shared.setUserConfig(config: UserConfig(user: User(uid: dir["uid"] as! String, lastName: dir["lastname"] as! String, firstName: dir["firstname"] as! String, birthday: dir["birthday"] as! String, sex: dir["sex"] as! String, phone: dir["phone"] as! String, address: dir["address"] as! String, password: dir["password"] as! String, avatar: dir["avatar"] as! String, friend: dir["friend"] as! [String]), cardmode: 0))
                        return true
                    }
                    return false
                }.isEmpty) {
                    subject.onNext(.success)
                } else if !(querySnapshot.documents.filter { (queryDocumentSnapshot) -> Bool in
                    let dir = queryDocumentSnapshot.data()
                    if (dir["uid"] as! String) == "\(lastName)_\(firstName)" {
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
                        ModelSingleton.shared.setUserConfig(config: UserConfig(user: oldUser, cardmode: oldCardMode))
                    }
                }
            }
        }
        return subject.asObserver()
    }
    // MARK: - 修改信箱及密碼
    func resetAddressPassword(newAddress: String, newPassword: String) -> Observable<Bool> {
        let subject = PublishSubject<Bool>()
        var userId = ""
        
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
            }
            guard !userId.isEmpty else {
                subject.onNext(false)
                return
            }
            let setter = !newAddress.isEmpty ? ["address" : newAddress] : ["password" : newPassword]
            FirebaseManager.shared.db.collection(DatabaseName.user.rawValue).document(userId).updateData(setter) { (error) in
                if let error = error {
                    NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                    subject.onError(error)
                } else {
                    subject.onNext(true)
                    var (oldUser, oldCardMode) = (ModelSingleton.shared.userConfig.user, ModelSingleton.shared.userConfig.cardmode)
                    if !newAddress.isEmpty {
                        oldUser.address = newAddress
                    } else {
                        oldUser.password = newPassword
                    }
                    ModelSingleton.shared.setUserConfig(config: UserConfig(user: oldUser, cardmode: oldCardMode))
                }
            }
        }
        return subject.asObserver()
    }
}
