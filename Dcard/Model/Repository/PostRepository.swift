//
//  PostRepository.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/6/27.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


protocol PostRepositoryInterface {
//    func getRecentPost(limit: String) -> Observable<FirebaseResult<[Post]>>
    func getComment(id: String) -> Observable<FirebaseResult<[Comment]>>
    func getForums() -> Observable<FirebaseResult<[Forum]>>
    func getPosts(alias: String, limit: String) -> Observable<FirebaseResult<[Post]>>
    func getBeforePost(id: String) -> Observable<FirebaseResult<[Post]>>
}
class PostRepository {
    public static let shared = PostRepository()
    private var disposeBag = DisposeBag()
    private var posts: [Post]!
    private var comments: [Comment]!
    let apiManager: APIManager
    init(apiManager: APIManager = APIManager.shared) {
        self.apiManager = apiManager
    }
}
extension PostRepository: PostRepositoryInterface {
    
    // MARK: - 取得最近貼文
    func getRecentPost(limit: String) -> Observable<FirebaseResult<[Post]>> {
        self.posts = [Post]()
        let subject = PublishSubject<FirebaseResult<[Post]>>()
        APIManager.shared.getPost(limit: limit).subscribe(onNext: { result in
            guard let count = result.json?.arrayObject?.count else {
                print("JSON分析錯誤")
                return
            }
            for index in 0..<count {
                let id = result.json![index]["id"].stringValue
                let title = result.json![index]["title"].stringValue
                let excerpt = result.json![index]["excerpt"].stringValue
                let createdAt = result.json![index]["createdAt"].stringValue
                let commentCount = result.json![index]["commentCount"].stringValue
                let likeCount = result.json![index]["likeCount"].stringValue
                let forumAlias = result.json![index]["forumAlias"].stringValue
                let forumName = result.json![index]["forumName"].stringValue
                let gender = result.json![index]["gender"].stringValue
                let school = result.json![index]["school"].stringValue
                let department = result.json![index]["department"].stringValue
                let anonymousSchool = result.json![index]["anonymousSchool"].boolValue
                let anonymousDepartment = result.json![index]["anonymousDepartment"].boolValue
                let withNickname = result.json![index]["withNickname"].boolValue
                var mediaMeta = [MediaMeta]()
                let list = result.json![index]["mediaMeta"].arrayValue
                for mediaMetaJson in list {
                    mediaMeta.append(MediaMeta(thumbnail: mediaMetaJson["thumbnail"].stringValue, normalizedUrl: mediaMetaJson["normalizedUrl"].stringValue))
                }
                self.posts.append(Post(id: id, title: title, excerpt: excerpt, createdAt: createdAt, commentCount: commentCount, likeCount: likeCount, forumAlias: forumAlias, forumName: forumName, gender: gender, department: department, anonymousSchool: anonymousSchool, anonymousDepartment: anonymousDepartment, school: school, withNickname: withNickname, mediaMeta: mediaMeta))
            }
            subject.onNext(FirebaseResult<[Post]>(data: self.posts, errorMessage: nil, sender: nil))
        }, onError: { error in
            subject.onError(error)
        }).disposed(by: disposeBag)
        
        return subject.asObserver()
    }
    
    // MARK: - 取得留言
    func getComment(id: String) -> Observable<FirebaseResult<[Comment]>> {
        self.comments = [Comment]()
        let subject = PublishSubject<FirebaseResult<[Comment]>>()
        APIManager.shared.getComment(id: id).subscribe(onNext: { result in
            guard let count = result.json?.arrayObject?.count else {
                print("JSON分析錯誤")
                return
            }
            for index in 0..<count {
                let id = result.json![index]["id"].stringValue
                let anonymous = result.json![index]["anonymous"].boolValue
                let content = result.json![index]["content"].stringValue
                let createdAt = result.json![index]["createdAt"].stringValue
                let floor = result.json![index]["floor"].intValue
                let likeCount = result.json![index]["likeCount"].intValue
                let gender = result.json![index]["gender"].stringValue
                let school = result.json![index]["school"].stringValue
                let department = result.json![index]["department"].stringValue
                let withNickname = result.json![index]["withNickname"].boolValue
                let host = result.json![index]["host"].boolValue
                var mediaMeta = [MediaMeta]()
                let list = result.json![index]["mediaMeta"].arrayValue
                for mediaMetaJson in list {
                    mediaMeta.append(MediaMeta(thumbnail: mediaMetaJson["thumbnail"].stringValue, normalizedUrl: mediaMetaJson["normalizedUrl"].stringValue))
                }
                self.comments.append(Comment(id: id, anonymous: anonymous, content: content, createdAt: createdAt, floor: floor, likeCount: likeCount, gender: gender, department: department, school: school, withNickname: withNickname, host: host, mediaMeta: mediaMeta))
            }
            subject.onNext(FirebaseResult<[Comment]>(data: self.comments, errorMessage: nil, sender: nil))
        }, onError: { error in
            subject.onError(error)
        }).disposed(by: disposeBag)
        return subject.asObserver()
    }
    // MARK: - 取得話題
    func getForums() -> Observable<FirebaseResult<[Forum]>> {
        var forums = [Forum]()
        let subject = PublishSubject<FirebaseResult<[Forum]>>()
        APIManager.shared.getForums().subscribe(onNext: { result in
            guard let count = result.json?.arrayObject?.count else {
                print("JSON分析錯誤")
                return
            }
            for index in 0..<count {
                let alias = result.json![index]["alias"].stringValue
                let name = result.json![index]["name"].stringValue
                let logo = result.json![index]["logo"]["url"].stringValue
                let postCount = result.json![index]["postCount"]["last30Days"].intValue
                forums.append(Forum(alias: alias, name: name, logo: logo, postCount: postCount))
            }
            ModelSingleton.shared.setForum(forums)
            subject.onNext(FirebaseResult<[Forum]>(data: forums, errorMessage: nil, sender: nil))
        }, onError: { error in
            subject.onError(error)
        }).disposed(by: disposeBag)
        return subject.asObserver()
    }
    // MARK: - 取得話題貼文
    func getPosts(alias: String, limit: String) -> Observable<FirebaseResult<[Post]>> {
        self.posts = [Post]()
        let subject = PublishSubject<FirebaseResult<[Post]>>()
        APIManager.shared.getPosts(alias: alias, limit: limit).subscribe(onNext: { result in
            guard let count = result.json?.arrayObject?.count else {
                print("JSON分析錯誤")
                return
            }
            for index in 0..<count {
                let id = result.json![index]["id"].stringValue
                let title = result.json![index]["title"].stringValue
                let excerpt = result.json![index]["excerpt"].stringValue
                let createdAt = result.json![index]["createdAt"].stringValue
                let commentCount = result.json![index]["commentCount"].stringValue
                let likeCount = result.json![index]["likeCount"].stringValue
                let forumAlias = result.json![index]["forumAlias"].stringValue
                let forumName = result.json![index]["forumName"].stringValue
                let gender = result.json![index]["gender"].stringValue
                let school = result.json![index]["school"].stringValue
                let department = result.json![index]["department"].stringValue
                let anonymousSchool = result.json![index]["anonymousSchool"].boolValue
                let anonymousDepartment = result.json![index]["anonymousDepartment"].boolValue
                let withNickname = result.json![index]["withNickname"].boolValue
                var mediaMeta = [MediaMeta]()
                let list = result.json![index]["mediaMeta"].arrayValue
                for mediaMetaJson in list {
                    mediaMeta.append(MediaMeta(thumbnail: mediaMetaJson["thumbnail"].stringValue, normalizedUrl: mediaMetaJson["normalizedUrl"].stringValue))
                }
                self.posts.append(Post(id: id, title: title, excerpt: excerpt, createdAt: createdAt, commentCount: commentCount, likeCount: likeCount, forumAlias: forumAlias, forumName: forumName, gender: gender, department: department, anonymousSchool: anonymousSchool, anonymousDepartment: anonymousDepartment, school: school, withNickname: withNickname, mediaMeta: mediaMeta))
            }
//            self.getBeforePost(id: self.posts[self.posts.count - 1].id).subscribe(onNext: { posts in
//                self.posts += posts.data
//                self.saveToFireBase(alias: alias, limit: limit, subject: subject)
//            }).disposed(by: self.disposeBag)
            self.saveToFireBase(alias: alias, limit: limit, subject: subject)
        }, onError: { error in
            subject.onError(error)
        }).disposed(by: disposeBag)
        
        return subject.asObserver()
    }
    // MARK: - Dcard資料存入Firebase
    private func saveToFireBase(alias: String, limit: String, subject: PublishSubject<FirebaseResult<[Post]>>) {
        var subjectList = [PublishSubject<Bool>]()
        for _ in self.posts {
            subjectList.append(PublishSubject<Bool>())
        }
        self.posts.enumerated().forEach { (key, post) in
            var mediaMetaDir: [[String: Any]] = []
            post.mediaMeta.forEach { (mediameta) in
                mediaMetaDir.append(["normalizedUrl": mediameta.normalizedUrl, "thumbnail": mediameta.thumbnail])
            }
            let setter: [String: Any] = ["\(post.id)": ["id": post.id, "title": post.title, "excerpt": post.excerpt, "createdAt": post.createdAt, "commentCount": post.commentCount, "likeCount": post.likeCount, "forumAlias": post.forumAlias, "forumName": post.forumName, "gender": post.gender
            , "department": post.department, "anonymousSchool": post.anonymousSchool, "anonymousDepartment": post.anonymousDepartment, "school": post.school, "withNickname": post.withNickname, "mediaMeta": mediaMetaDir, "host": post.host
                , "hot": post.hot]]
            FirebaseManager.shared.db.collection(DatabaseName.allPost.rawValue).document(alias).setData(setter, merge: true) { (error) in
                if let error = error {
                    NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                    subjectList[key].onNext(false)
                } else {
                    subjectList[key].onNext(true)
                }
            }
        }
        Observable.combineLatest(subjectList).subscribe(onNext: { (result) in
            if result.filter({ return !$0}).isEmpty {
                subject.onNext(FirebaseResult<[Post]>(data: self.posts, errorMessage: nil, sender: nil))
            }
        }, onError: { (error) in
            subject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    // MARK: - 取得特定貼文以前貼文
    func getBeforePost(id: String) -> Observable<FirebaseResult<[Post]>> {
        var posts = [Post]()
        let subject = PublishSubject<FirebaseResult<[Post]>>()
        APIManager.shared.getBeforePost(id: id).subscribe(onNext: { result in
            guard let count = result.json?.arrayObject?.count else {
                print("JSON分析錯誤")
                return
            }
            for index in 0..<count {
                let id = result.json![index]["id"].stringValue
                let title = result.json![index]["title"].stringValue
                let excerpt = result.json![index]["excerpt"].stringValue
                let createdAt = result.json![index]["createdAt"].stringValue
                let commentCount = result.json![index]["commentCount"].stringValue
                let likeCount = result.json![index]["likeCount"].stringValue
                let forumAlias = result.json![index]["forumAlias"].stringValue
                let forumName = result.json![index]["forumName"].stringValue
                let gender = result.json![index]["gender"].stringValue
                let school = result.json![index]["school"].stringValue
                let department = result.json![index]["department"].stringValue
                let anonymousSchool = result.json![index]["anonymousSchool"].boolValue
                let anonymousDepartment = result.json![index]["anonymousDepartment"].boolValue
                let withNickname = result.json![index]["withNickname"].boolValue
                var mediaMeta = [MediaMeta]()
                let list = result.json![index]["mediaMeta"].arrayValue
                for mediaMetaJson in list {
                    mediaMeta.append(MediaMeta(thumbnail: mediaMetaJson["thumbnail"].stringValue, normalizedUrl: mediaMetaJson["normalizedUrl"].stringValue))
                }
                posts.append(Post(id: id, title: title, excerpt: excerpt, createdAt: createdAt, commentCount: commentCount, likeCount: likeCount, forumAlias: forumAlias, forumName: forumName, gender: gender, department: department, anonymousSchool: anonymousSchool, anonymousDepartment: anonymousDepartment, school: school, withNickname: withNickname, mediaMeta: mediaMeta))
            }
            subject.onNext(FirebaseResult<[Post]>(data: posts, errorMessage: nil, sender: nil))
        }, onError: { error in
            subject.onError(error)
        }).disposed(by: disposeBag)
        
        return subject.asObserver()
    }
}
