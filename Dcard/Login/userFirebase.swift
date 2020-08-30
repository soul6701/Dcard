//
//  Firebase.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/28.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Firebase

enum LoginType {
    case success
    case error(LoginErroType)
}
enum LoginErroType: String {
    case account = "找不到此用戶"
    case password = "密碼錯誤"
}
protocol UserFirebaseInterface {
    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String) -> Observable<Bool>
//    func readFromUserData(lastName: String, firstName: String, password: String) -> Observable<(User?)>
    func login(lastName: String, firstName: String, password: String) -> Observable<LoginType>
}

class UserFirebase: UserFirebaseInterface {
    public static var shared = UserFirebase()
    private var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String) -> Observable<Bool> {
        let subject = PublishSubject<Bool>()
        db.collection("user").addDocument(data: ["uid": "\(lastName)_\(firstName)", "lastname": lastName, "firstname": firstName, "birthday": birthday, "sex": sex, "phone": phone, "address": address, "password": password]) { (error) in
            if let error = error {
                subject.onError(error)
            } else {
                subject.onNext(true)
            }
        }
        return subject.asObserver()
    }
//    func readFromUserData(lastName: String, firstName: String, password: String) -> Observable<User?> {
//        let subject = AsyncSubject<User?>()
//        db.collection("user").getDocuments { (querySnapshot, error) in
//            if let error = error {
//                subject.onError(error)
//            }
//            if let querySnapshot = querySnapshot {
//                querySnapshot.documents.forEach { (queryDocumentSnapshot) in
//                    if let dir = queryDocumentSnapshot.data() as? [String: String] {
//                        if dir["uid"] == "\(lastName)_\(firstName)_\(password)" {
//                            subject.onNext(User(lastName: dir["lastname"] ?? "", firstName: dir["firstname"] ?? "", birthday: dir["birthday"] ?? "", sex: dir["sex"] ?? "", phone: dir["phone"] ?? "", address: dir["address"] ?? "", password: dir["password"] ?? ""))
//                            subject.onCompleted()
//                        }
//                        if dir["lastname"] == lastName && dir["firstname"] == firstName && dir["password"] != password {
//                            subject.onNext(User(lastName: <#T##String#>, firstName: <#T##String#>, birthday: <#T##String#>, sex: <#T##String#>, phone: <#T##String#>, address: <#T##String#>, password: <#T##String#>))
//                        }
//
//                    }
//                }
//            }
//        }
//        return subject.asObserver()
//    }
    func login(lastName: String, firstName: String, password: String) -> Observable<LoginType> {
        let subject = PublishSubject<LoginType>()
        
        db.collection("user").getDocuments { (querySnapshot, error) in
            
            if let error = error {
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot {
                querySnapshot.documents.forEach { (queryDocumentSnapshot) in
                    if let dir = queryDocumentSnapshot.data() as? [String:String] {
                        if dir["uid"] == "\(lastName)_\(firstName)" && dir["password"] == password {
                            subject.onNext(.success)
                        } else if dir["uid"] == "\(lastName)_\(firstName)" {
                            subject.onNext(.error(.password))
                        } else {
                            subject.onNext(.error(.account))
                        }
                    }
                }
            }
        }
        return subject.asObserver()
    }
}
public struct User {
    
    public let lastName: String
    public let firstName: String
    public let birthday: String
    public let sex: String
    public var phone: String
    public var address: String
    public let password: String
}
