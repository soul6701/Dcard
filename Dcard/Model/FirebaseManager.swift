//
//  FirebaseManager.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/30.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseFirestore

enum DeleteCollectionType {
    case success(String)
    case error(String)
}
enum DatabaseName: String {
    case user
    case card
    case favoritePost
    case comment
    case post
    case allPost
    case forum
}
class FirebaseManager {
    static var shared = FirebaseManager()
    
    var db: Firestore = Firestore.firestore()
    
    ///刪除資料庫集合
    var deleteCollection = { (db: Firestore, name: String) -> PublishSubject<DeleteCollectionType> in
        let subject = PublishSubject<DeleteCollectionType>()
        
        db.collection(name).getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot {
                if querySnapshot.documents.isEmpty {
                    subject.onNext(.error("無任何使用者資料"))
                } else {
                    querySnapshot.documents.forEach { (queryDocumentSnapshot) in
                        queryDocumentSnapshot.reference.delete { (error) in
                            if let error = error {
                                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                                subject.onError(error)
                                subject.onNext(.error("刪除資料失敗"))
                            } else {
                                subject.onNext(.success("刪除資料成功"))
                            }
                        }
                    }
                }
            }
        }
        return subject.asObserver()
    }
}
