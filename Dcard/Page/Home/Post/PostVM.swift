//
//  PostVM.swift
//  Dcard
//
//  Created by Mason on 2020/10/29.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Firebase
import UIKit
import RxSwift
import RxCocoa

protocol PostVMInterface {
    ///加入收藏清單
    func addFavoriteList(listName: String, postID: String)
    var addFavoriteListSubject: PublishSubject<FirebaseResult<Bool>> { get }
    ///取得使用者貼文
    func getPostInfo(uid: String)
    var getPostInfoSubject: PublishSubject<FirebaseResult<[Post]>> { get }
    ///添加收藏清單
    func createFavoriteList(listName: String)
    var createFavoriteListSubject: PublishSubject<FirebaseResult<Bool>> { get }
    ///取得所有貼文
    func getPostInfoOfList(postIDs: [String])
    var getPostInfoOfListSubject: PublishSubject<FirebaseResult<[Post]>> { get }
}
class PostVM: PostVMInterface {
    private(set) var addFavoriteListSubject = PublishSubject<FirebaseResult<Bool>>()
    private(set) var getPostInfoSubject = PublishSubject<FirebaseResult<[Post]>>()
    private(set) var createFavoriteListSubject = PublishSubject<FirebaseResult<Bool>>()
    private(set) var getPostInfoOfListSubject = PublishSubject<FirebaseResult<[Post]>>()
    
    private var postFirebase: PostFirebaseInterface
    private let disposeBag = DisposeBag()
    
    init(postFirebase: PostFirebaseInterface = PostFirebase.shared) {
        self.postFirebase = postFirebase
    }
}
extension PostVM {
    func addFavoriteList(listName: String, postID: String) {
        self.postFirebase.addFavoriteList(listName: listName, postID: postID).subscribe(onNext: { (result) in
            self.addFavoriteListSubject.onNext(result)
        }, onError: { (error) in
            self.addFavoriteListSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func getPostInfo(uid: String) {
        self.postFirebase.getPostInfo(uid: uid).subscribe(onNext: { (result) in
            self.getPostInfoSubject.onNext(result)
        }, onError: { (error) in
            self.getPostInfoSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func createFavoriteList(listName: String) {
        self.postFirebase.createFavoriteList(listName: listName).subscribe(onNext: { (result) in
            self.createFavoriteListSubject.onNext(result)
        }, onError: { (error) in
            self.createFavoriteListSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func getPostInfoOfList(postIDs: [String]) {
        self.postFirebase.getPostInfoOfList(postIDs: postIDs).subscribe(onNext: { (result) in
            self.getPostInfoOfListSubject.onNext(result)
        }, onError: { (error) in
            self.getPostInfoOfListSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
}
