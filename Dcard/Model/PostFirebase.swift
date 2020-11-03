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
    func addFavoriteList(listName: String, postID: String) -> Observable<FirebaseResult<Bool>>
    func getPostInfo(uid: String) -> Observable<FirebaseResult<[Post]>>
    func createFavoriteList(listName: String) -> Observable<FirebaseResult<Bool>>
}
public class PostFirebase: PostFirebaseInterface {

    public static var shared = PostFirebase()
    private var user: User {
        return ModelSingleton.shared.userConfig.user
    }
    private let disposeBag = DisposeBag()

    // MARK: - 取得使用者貼文
    func getPostInfo(uid: String) -> Observable<FirebaseResult<[Post]>> {
        let subject = PublishSubject<FirebaseResult<[Post]>>()
        var postList = [Post]()
        var subjectList = [PublishSubject<Bool>]()
        
        FirebaseManager.shared.db.collection(DatabaseName.post.rawValue).document(uid).getDocument { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot, let dir = querySnapshot.data() {
                let postListArray = dir["postnotRead"] as! [String]
                for _ in postListArray {
                    subjectList.append(PublishSubject<Bool>())
                }
                postListArray.enumerated().forEach { (key, value) in
                    FirebaseManager.shared.db.collection(DatabaseName.allPost.rawValue).document(value).getDocument { (querySnapshot, error) in
                        if let error = error {
                            NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                            subject.onError(error)
                        }
                        if let querySnapshot = querySnapshot, let dir = querySnapshot.data() {
                            var mediaMetaList = [MediaMeta]()
                            let mediaMetaListDir = dir["mediaMeta"] as! [[String: Any]]
                            mediaMetaListDir.forEach { (mediaMetaDir) in
                                let dir = mediaMetaDir as! [String: String]
                                mediaMetaList.append(MediaMeta(thumbnail: dir["thumbnail"]!, normalizedUrl: dir["normalizedUrl"]!))
                            }
                            postList.append(Post(id: dir["id"] as! String, title: dir["title"] as! String, excerpt: dir["excerpt"] as! String, createdAt: dir["createdAt"] as! String, commentCount: dir["commentCount"] as! String, likeCount: dir["likeCount"] as! String, forumName: dir["forumName"] as! String, gender: dir["gender"] as! String, department: dir["department"] as! String, anonymousSchool: dir["anonymousSchool"] as! Bool, anonymousDepartment: dir["anonymousDepartment"] as! Bool, school: dir["school"] as! String, withNickname: dir["withNickname"] as! Bool, mediaMeta: mediaMetaList, host: dir["host"] as! Bool, hot: dir["hot"] as! Bool))
                            subjectList[key].onNext(true)
                        }
                    }
                }
                Observable.combineLatest(subjectList).subscribe { (result) in
                    let count: Int = result.element?.reduce(Int(0)) { (result, next) -> Int in
                        return result + (next ? 1 : 0)
                    } ?? 0
                    if count == result.element?.count {
                        if uid == self.user.uid {
                            ModelSingleton.shared.setPostList(postList)
                        }
                        subject.onNext(FirebaseResult<[Post]>(data: postList, errorMessage: nil))
                    }
                }.disposed(by: self.disposeBag)
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
                        return (dir["uid"] as! String) == self.user.uid
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
                        var (oldUser, oldCardMode) = (self.user, ModelSingleton.shared.userConfig.cardmode)
                        oldUser.friend = friendList
                        ModelSingleton.shared.setUserConfig(UserConfig(user: oldUser, cardmode: oldCardMode))
                    }
                }
            }
        }
        return subject.asObserver()
    }
    
    // MARK: - 添加收藏清單
    func createFavoriteList(listName: String) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        
        let setter: [String: Any] = [listName: ["createAt": FieldValue.serverTimestamp(), "post": []]]
        FirebaseManager.shared.db.collection(DatabaseName.favoritePost.rawValue).document(self.user.uid).setData(setter, merge: true) { (error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                var oldFavorite = ModelSingleton.shared.favorite
                oldFavorite.append(Favorite(title: listName, posts: []))
                ModelSingleton.shared.setFavoriteList(oldFavorite)
                subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: nil))
            }
        }
        return subject.asObserver()
    }
    // MARK: - 加入收藏清單
    func addFavoriteList(listName: String, postID: String) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        
        FirebaseManager.shared.db.collection(DatabaseName.favoritePost.rawValue).document(user.uid).updateData(["\(listName).post": FieldValue.arrayUnion([postID])]) { (error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: nil))
                
                FirebaseManager.shared.db.collection(DatabaseName.allPost.rawValue).document(postID).getDocument { (querySnapshot, error) in
                    if let error = error {
                        NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                        subject.onError(error)
                    }
                    if let querySnapshot = querySnapshot, let dir = querySnapshot.data() {
                        var mediaMetaList = [MediaMeta]()
                        let mediaMetaListDir = dir["mediaMeta"] as! [[String: Any]]
                        mediaMetaListDir.forEach { (mediaMetaDir) in
                            let dir = mediaMetaDir as! [String: String]
                            mediaMetaList.append(MediaMeta(thumbnail: dir["thumbnail"]!, normalizedUrl: dir["normalizedUrl"]!))
                        }
                        let post = Post(id: dir["id"] as! String, title: dir["title"] as! String, excerpt: dir["excerpt"] as! String, createdAt: dir["createdAt"] as! String, commentCount: dir["commentCount"] as! String, likeCount: dir["likeCount"] as! String, forumName: dir["forumName"] as! String, gender: dir["gender"] as! String, department: dir["department"] as! String, anonymousSchool: dir["anonymousSchool"] as! Bool, anonymousDepartment: dir["anonymousDepartment"] as! Bool, school: dir["school"] as! String, withNickname: dir["withNickname"] as! Bool, mediaMeta: mediaMetaList, host: dir["host"] as! Bool, hot: dir["hot"] as! Bool)
                        
                        var favoriteList = ModelSingleton.shared.favorite
                        let index = favoriteList.firstIndex { return $0.title == listName} ?? 0
                        favoriteList[index].posts.append(post)
                        ModelSingleton.shared.setFavoriteList(favoriteList)
                    }
                }
            }
        }
        return subject.asObserver()
    }
}
