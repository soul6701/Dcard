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
    func addFavoriteList(listName: String, postID: String, Alias: String) -> Observable<FirebaseResult<Bool>>
    func getPostInfo(uid: String) -> Observable<FirebaseResult<[Post]>>
    func createFavoriteList(listName: String) -> Observable<FirebaseResult<Bool>>
    func getPosts(alias: String, limit: String) -> Observable<FirebaseResult<[Post]>>
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
        
        FirebaseManager.shared.db.collection(DatabaseName.allPost.rawValue).document(alias).getDocument { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot, let dir = querySnapshot.data() {
                for dir in dir.values {
                    let _dir = dir as! [String: Any]
                    var mediaMetaList = [MediaMeta]()
                    let mediaMetaListDir = _dir["mediaMeta"] as! [[String: Any]]
                    mediaMetaListDir.forEach { (mediaMetaDir) in
                        let dir = mediaMetaDir as! [String: String]
                        mediaMetaList.append(MediaMeta(thumbnail: dir["thumbnail"]!, normalizedUrl: dir["normalizedUrl"]!))
                    }
                    postList.append(Post(id: _dir["id"] as! String, title: _dir["title"] as! String, excerpt: _dir["excerpt"] as! String, createdAt: _dir["createdAt"] as! String, commentCount: _dir["commentCount"] as! String, likeCount: _dir["likeCount"] as! String, forumAlias: _dir["forumAlias"] as! String, forumName: _dir["forumName"] as! String, gender: _dir["gender"] as! String, department: _dir["department"] as! String, anonymousSchool: _dir["anonymousSchool"] as! Bool, anonymousDepartment: _dir["anonymousDepartment"] as! Bool, school: _dir["school"] as! String, withNickname: _dir["withNickname"] as! Bool, mediaMeta: mediaMetaList, host: _dir["host"] as! Bool, hot: _dir["hot"] as! Bool))
                    if postList.count == Int(limit) {
                        break
                    }
                }
                subject.onNext(FirebaseResult<[Post]>(data: postList, errorMessage: nil, sender: nil))
            }
        }
        return subject.asObservable()
    }
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
                            postList.append(Post(id: dir["id"] as! String, title: dir["title"] as! String, excerpt: dir["excerpt"] as! String, createdAt: dir["createdAt"] as! String, commentCount: dir["commentCount"] as! String, likeCount: dir["likeCount"] as! String, forumAlias: dir["forumAlias"] as! String, forumName: dir["forumName"] as! String, gender: dir["gender"] as! String, department: dir["department"] as! String, anonymousSchool: dir["anonymousSchool"] as! Bool, anonymousDepartment: dir["anonymousDepartment"] as! Bool, school: dir["school"] as! String, withNickname: dir["withNickname"] as! Bool, mediaMeta: mediaMetaList, host: dir["host"] as! Bool, hot: dir["hot"] as! Bool))
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
        return subject.asObservable()
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
        return subject.asObservable()
    }
    // MARK: - 加入收藏清單
    func addFavoriteList(listName: String, postID: String, Alias: String) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        
        FirebaseManager.shared.db.collection(DatabaseName.favoritePost.rawValue).document(user.uid).updateData(["\(listName).post": FieldValue.arrayUnion([postID])]) { (error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                FirebaseManager.shared.db.collection(DatabaseName.allPost.rawValue).document(Alias).getDocument { (querySnapshot, error) in
                    if let error = error {
                        NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                        subject.onError(error)
                    }
                    if let querySnapshot = querySnapshot, let dir = querySnapshot.data()?[postID] as? [String: Any] {
                        var mediaMetaList = [MediaMeta]()
                        let mediaMetaListDir = dir["mediaMeta"] as! [[String: Any]]
                        mediaMetaListDir.forEach { (mediaMetaDir) in
                            let dir = mediaMetaDir as! [String: String]
                            mediaMetaList.append(MediaMeta(thumbnail: dir["thumbnail"]!, normalizedUrl: dir["normalizedUrl"]!))
                        }
                        let post = Post(id: dir["id"] as! String, title: dir["title"] as! String, excerpt: dir["excerpt"] as! String, createdAt: dir["createdAt"] as! String, commentCount: dir["commentCount"] as! String, likeCount: dir["likeCount"] as! String, forumAlias: dir["forumAlias"] as! String, forumName: dir["forumName"] as! String, gender: dir["gender"] as! String, department: dir["department"] as! String, anonymousSchool: dir["anonymousSchool"] as! Bool, anonymousDepartment: dir["anonymousDepartment"] as! Bool, school: dir["school"] as! String, withNickname: dir["withNickname"] as! Bool, mediaMeta: mediaMetaList, host: dir["host"] as! Bool, hot: dir["hot"] as! Bool)
                        
                        var favoriteList = ModelSingleton.shared.favorite
                        let index = favoriteList.firstIndex { return $0.title == listName} ?? 0
                        favoriteList[index].posts.append(post)
                        ModelSingleton.shared.setFavoriteList(favoriteList)
                        subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: nil))
                    }
                }
            }
        }
        return subject.asObservable()
    }
}
