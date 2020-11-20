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
    func addFavoriteList(listName: String, postID: String, coverImage: String)
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
    ///移除收藏清單
    func removeFavoriteList(listName: String)
    var removeFavoriteListSubject: PublishSubject<FirebaseResult<Bool>> { get }
    ///更改收藏清單名字
    func updateFavoriteList(oldListName: String, newListName: String)
    var updateFavoriteListSubject: PublishSubject<FirebaseResult<Bool>> { get }
    ///移除收藏清單貼文
    func removePostFromFavoriteList(postID: String)
    var removePostFromFavoriteListSubject: PublishSubject<FirebaseResult<Bool>> { get }
    ///加入表情符號
    func addMood(emotion: Mood.EmotionType, postID: String)
    var addMoodSubject: PublishSubject<FirebaseResult<Bool>> { get }
    ///移除表情符號
    func removeMood(emotion: Mood.EmotionType, postID: String)
    var removeMoodSubject: PublishSubject<FirebaseResult<Bool>> { get }
}
class PostVM: PostVMInterface {
    private(set) var addFavoriteListSubject = PublishSubject<FirebaseResult<Bool>>()
    private(set) var getPostInfoSubject = PublishSubject<FirebaseResult<[Post]>>()
    private(set) var createFavoriteListSubject = PublishSubject<FirebaseResult<Bool>>()
    private(set) var getPostInfoOfListSubject = PublishSubject<FirebaseResult<[Post]>>()
    private(set) var removeFavoriteListSubject = PublishSubject<FirebaseResult<Bool>>()
    private(set) var updateFavoriteListSubject = PublishSubject<FirebaseResult<Bool>>()
    private(set) var removePostFromFavoriteListSubject = PublishSubject<FirebaseResult<Bool>>()
    private(set) var addMoodSubject = PublishSubject<FirebaseResult<Bool>>()
    private(set) var removeMoodSubject = PublishSubject<FirebaseResult<Bool>>()
    
    private var postFirebase: PostFirebaseInterface
    private var favoriteFirebase: FavoriteFirebaseInterface
    private var cardFirbase: CardFirebaseInterface
    private let disposeBag = DisposeBag()
    
    init(postFirebase: PostFirebaseInterface = PostFirebase.shared, favoriteFirebase: FavoriteFirebaseInterface = FavoriteFirebase.shared, cardFirbase: CardFirebaseInterface = CardFirebase.shared) {
        self.postFirebase = postFirebase
        self.favoriteFirebase = favoriteFirebase
        self.cardFirbase = cardFirbase
    }
}
extension PostVM {
    func addFavoriteList(listName: String, postID: String, coverImage: String) {
        self.favoriteFirebase.addFavoriteList(listName: listName, postID: postID, coverImage: coverImage).subscribe(onNext: { (result) in
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
        self.favoriteFirebase.createFavoriteList(listName: listName).subscribe(onNext: { (result) in
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
    func removeFavoriteList(listName: String) {
        self.favoriteFirebase.removeFavoriteList(listName: listName).subscribe(onNext: { (result) in
            self.removeFavoriteListSubject.onNext(result)
        }, onError: { (error) in
            self.removeFavoriteListSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func updateFavoriteList(oldListName: String, newListName: String) {
        self.favoriteFirebase.updateFavoriteList(oldListName: oldListName, newListName: newListName).subscribe(onNext: { (result) in
            self.updateFavoriteListSubject.onNext(result)
        }, onError: { (error) in
            self.updateFavoriteListSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func removePostFromFavoriteList(postID: String) {
        self.favoriteFirebase.removePostFromFavoriteList(postID: postID).subscribe(onNext: { (result) in
            self.removePostFromFavoriteListSubject.onNext(result)
        }, onError: { (error) in
            self.removePostFromFavoriteListSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func addMood(emotion: Mood.EmotionType, postID: String) {
        self.cardFirbase.addMood(emotion: emotion, postID: postID).subscribe(onNext: { (result) in
            self.addMoodSubject.onNext(result)
        }, onError: { (error) in
            self.addMoodSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func removeMood(emotion: Mood.EmotionType, postID: String) {
        self.cardFirbase.removeMood(emotion: emotion, postID: postID).subscribe(onNext: { (result) in
            self.removeMoodSubject .onNext(result)
        }, onError: { (error) in
            self.removeMoodSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
}
