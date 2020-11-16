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
    ///加入收藏清單
    func addFavoriteList(listName: String, postID: String) -> Observable<FirebaseResult<Bool>>
    ///取得使用者貼文
    func getPostInfo(uid: String) -> Observable<FirebaseResult<[Post]>>
    ///添加收藏清單
    func createFavoriteList(listName: String) -> Observable<FirebaseResult<Bool>>
    ///取得話題貼文
    func getPosts(alias: String, limit: String) -> Observable<FirebaseResult<[Post]>>
    ///取得所有貼文
    func getPostInfoOfList(postIDs: [String]) -> Observable<FirebaseResult<[Post]>>
}
public class PostFirebase: PostFirebaseInterface {

    public static var shared = PostFirebase()
    private var user: User {
        return ModelSingleton.shared.userConfig.user
    }
    private let disposeBag = DisposeBag()

    // MARK: - 取得話題貼文
    func getPosts(alias: String, limit: String) -> Observable<FirebaseResult<[Post]>> {
        let subject = PublishSubject<FirebaseResult<[Post]>>()
        var postList = [Post]()
        
        FirebaseManager.shared.db.collection(DatabaseName.forum.rawValue).document(alias).getDocument { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot, let dir = querySnapshot.data() {
                let postIDList: [String] = dir["postList"] as! [String]
                
                postIDList[0...((Int(limit) ?? 0) - 1)].forEach { (id) in
                    FirebaseManager.shared.db.collection(DatabaseName.allPost.rawValue).document(id).getDocument { (querySnapshot, error) in
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
                            postList.append(Post(id: dir["id"] as! String, title: dir["title"] as! String, excerpt: dir["excerpt"] as! String, createdAt: dir["createdAt"] as! String, commentCount: dir["commentCount"] as! String, likeCount: dir["likeCount"] as! String, forumAlias: dir["forumAlias"] as! String, forumName: dir["forumName"] as! String, gender: dir["gender"] as! String, department: dir["department"] as! String, anonymousSchool: dir["anonymousSchool"] as! Bool, anonymousDepartment: dir["anonymousDepartment"] as! Bool, school: dir["school"] as! String, withNickname: dir["withNickname"] as! Bool, mediaMeta: mediaMetaList, host: dir["host"] as! String, hot: dir["hot"] as! Bool))
                            subject.onNext(FirebaseResult<[Post]>(data: postList, errorMessage: nil, sender: nil))
                        }
                    }
                }
            }
        }
        return subject.asObservable()
    }
    // MARK: - 取得使用者貼文
    func getPostInfo(uid: String) -> Observable<FirebaseResult<[Post]>> {
        let subject = PublishSubject<FirebaseResult<[Post]>>()
        var postList = [Post]()
        
        FirebaseManager.shared.db.collection(DatabaseName.post.rawValue).document(uid).getDocument { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot, let dir = querySnapshot.data() {
                let postListArray = dir["postnotRead"] as! [String]
                postListArray.forEach { (post) in
                    FirebaseManager.shared.db.collection(DatabaseName.allPost.rawValue).document(post).getDocument { (querySnapshot, error) in
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
                            postList.append(Post(id: dir["id"] as! String, title: dir["title"] as! String, excerpt: dir["excerpt"] as! String, createdAt: dir["createdAt"] as! String, commentCount: dir["commentCount"] as! String, likeCount: dir["likeCount"] as! String, forumAlias: dir["forumAlias"] as! String, forumName: dir["forumName"] as! String, gender: dir["gender"] as! String, department: dir["department"] as! String, anonymousSchool: dir["anonymousSchool"] as! Bool, anonymousDepartment: dir["anonymousDepartment"] as! Bool, school: dir["school"] as! String, withNickname: dir["withNickname"] as! Bool, mediaMeta: mediaMetaList, host: dir["host"] as! String, hot: dir["hot"] as! Bool))
                            subject.onNext(FirebaseResult<[Post]>(data: postList, errorMessage: nil))
                        }
                    }
                }
            }
        }
        return subject.asObservable()
    }
    
    // MARK: - 添加收藏清單
    func createFavoriteList(listName: String) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        FirebaseManager.shared.db.collection(DatabaseName.favoritePost.rawValue).document(self.user.uid).updateData(["favorite" : FieldValue.arrayUnion([["title": listName, "createAt": Date.getCurrentDateString(true), "post": []]])]) { (error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                var oldFavorite = ModelSingleton.shared.favorite
                oldFavorite.append(Favorite(title: listName, createAt: Date.getCurrentDateString(true), postIDList: []))
                ModelSingleton.shared.setFavoriteList(oldFavorite)
                subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: nil))
            }
        }
        return subject.asObservable()
    }
    // MARK: - 加入收藏清單
    func addFavoriteList(listName: String, postID: String) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        
        FirebaseManager.shared.db.collection(DatabaseName.favoritePost.rawValue).document(user.uid).updateData(["\(listName).post": FieldValue.arrayUnion([postID])]) { (error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                var oldFavoriteList = ModelSingleton.shared.favorite
                if let index = oldFavoriteList.firstIndex(where: { $0.title == listName }) {
                    oldFavoriteList[index].postIDList.append(postID)
                    ModelSingleton.shared.setFavoriteList(oldFavoriteList)
                    subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: nil))
                }
            }
        }
        return subject.asObservable()
    }
    // MARK: - 取得所有貼文
    func getPostInfoOfList(postIDs: [String]) -> Observable<FirebaseResult<[Post]>> {
        let subject = PublishSubject<FirebaseResult<[Post]>>()
        var postList = [Post]()
        
        postIDs.forEach { (id) in
            FirebaseManager.shared.db.collection(DatabaseName.allPost.rawValue).document(id).getDocument { (querySnapshot, error) in
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
                    postList.append(Post(id: dir["id"] as! String, title: dir["title"] as! String, excerpt: dir["excerpt"] as! String, createdAt: dir["createdAt"] as! String, commentCount: dir["commentCount"] as! String, likeCount: dir["likeCount"] as! String, forumAlias: dir["forumAlias"] as! String, forumName: dir["forumName"] as! String, gender: dir["gender"] as! String, department: dir["department"] as! String, anonymousSchool: dir["anonymousSchool"] as! Bool, anonymousDepartment: dir["anonymousDepartment"] as! Bool, school: dir["school"] as! String, withNickname: dir["withNickname"] as! Bool, mediaMeta: mediaMetaList, host: dir["host"] as! String, hot: dir["hot"] as! Bool))
                    subject.onNext(FirebaseResult<[Post]>(data: postList, errorMessage: nil))
                }
            }
        }
        return subject
    }
}
