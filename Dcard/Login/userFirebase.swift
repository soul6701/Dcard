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
protocol UserFirebaseInterface {
    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String, avatar: Data?) -> Observable<Bool>
    func login(lastName: String, firstName: String, password: String) -> Observable<LoginType>
    func deleteUserData() -> PublishSubject<DeleteCollectionType>
    func expectAccount(lastName: String, firstName: String) -> Observable<Bool>
    func requirePassword(uid: String, phone: String?, address: String?) -> Observable<RequirePasswordType>
}

public class UserFirebase: UserFirebaseInterface {
    public static var shared = UserFirebase()
    private var databaseName = "user"
    
    // MARK: - 創建帳戶
    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String, avatar: Data?) -> Observable<Bool> {
        let subject = PublishSubject<Bool>()
        let uid = "\(lastName)_\(firstName)"
        var avatarUrl = ""
        
        if let avatar = avatar {
            let ref = Storage.storage().reference().child(self.databaseName).child(uid + ".png")
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
        FirebaseManager.shared.db.collection(databaseName).addDocument(data: ["uid": uid, "firstname": firstName, "lastname": lastName, "birthday": birthday, "sex": sex, "phone": phone, "address": address, "password": password, "avatar": avatarUrl]) { (error) in
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
        var result = true
        FirebaseManager.shared.db.collection(databaseName).getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot {
                querySnapshot.documents.forEach { (queryDocumentSnapshot) in
                    if let dir = queryDocumentSnapshot.data() as? [String:String] {
                        if dir["uid"] == uid {
                            result = false
                        }
                    }
                }
            }
            subject.onNext(result)
        }
        return subject.asObserver()
    }
    
    // MARK: - 刪除所有使用者資料
    func deleteUserData() -> PublishSubject<DeleteCollectionType> {
        return FirebaseManager.shared.deleteCollection(FirebaseManager.shared.db, self.databaseName)
    }
    
    // MARK: - 登入
    func login(lastName: String, firstName: String, password: String) -> Observable<LoginType> {
        let subject = PublishSubject<LoginType>()
        
        FirebaseManager.shared.db.collection(databaseName).getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
                if !(querySnapshot.documents.filter { (queryDocumentSnapshot) -> Bool in
                    if let dir = queryDocumentSnapshot.data() as? [String:String] {
                        if dir["uid"] == "\(lastName)_\(firstName)" && dir["password"] == password {
                            ModelSingleton.shared.setUserConfig(config: UserConfig(user: User(uid: dir["uid"]!, lastName: dir["lastName"]!, firstName: dir["firstName"]!, birthday: dir["birthday"]!, sex: dir["sex"]!, phone: dir["phone"]!, address: dir["address"]!, password: dir["password"]!, avatar: dir["avatar"]!), cardmode: 0))
                            return true
                        }
                    }
                    return false
                }.isEmpty) {
                    subject.onNext(.success)
                } else if !(querySnapshot.documents.filter { (queryDocumentSnapshot) -> Bool in
                    if let dir = queryDocumentSnapshot.data() as? [String:String] {
                        if dir["uid"] == "\(lastName)_\(firstName)" {
                            return true
                        }
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
        
        FirebaseManager.shared.db.collection(self.databaseName).getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
                if !(querySnapshot.documents.filter { (queryDocumentSnapshot) -> Bool in
                    if let dir = queryDocumentSnapshot.data() as? [String:String] {
                        if let phone = phone {
                            let _phone = "243-" + phone
                            if dir["uid"] == uid && dir["phone"] == _phone {
                                if let password = dir["password"] {
                                    successString = password
                                }
                                return true
                            }
                        }
                        if let address = address {
                            if dir["uid"] == uid && dir["address"] == address {
                                if let password = dir["password"] {
                                    successString = password
                                }
                                return true
                            }
                        }
                    }
                    return false
                }.isEmpty) {
                    subject.onNext(.success(successString))
                } else if !(querySnapshot.documents.filter { (queryDocumentSnapshot) -> Bool in
                    if let dir = queryDocumentSnapshot.data() as? [String:String] {
                        if dir["uid"] == uid {
                            return true
                        }
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
    
        FirebaseManager.shared.db.collection(self.databaseName).getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot {
                let document = querySnapshot.documents.first { (queryDocumentSnapshot) -> Bool in
                    if let dir = queryDocumentSnapshot.data() as? [String:String] {
                        return dir["uid"] == uid
                    }
                    return false
                }
                
                if let document = document, let user = document.data() as? [String:String] {
                    subject.onNext(User(uid: user["uid"]!, lastName: user["lastname"]!, firstName: user["firstname"]!, birthday: user["birthday"]!, sex: user["sex"]!, phone: user["phone"]!, address: user["address"]!, password: user["password"]!, avatar: user["avatar"]!))
                }
            }
        }
        return subject.asObserver()
    }
}
