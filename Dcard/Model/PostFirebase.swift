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
    ///取得使用者貼文
    func getPostInfo(uid: String) -> Observable<FirebaseResult<[Post]>>
    ///取得話題貼文
    func getPosts(alias: String, limit: String) -> Observable<FirebaseResult<[Post]>>
    ///取得所有貼文
    func getPostInfoOfList(postIDs: [String]) -> Observable<FirebaseResult<[Post]>>
}
public class PostFirebase: PostFirebaseInterface {

    public static var shared = PostFirebase()
    private let disposeBag = DisposeBag()

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
