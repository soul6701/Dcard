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
    func getRecentPost(limit: String) -> Observable<[Post]> //取得最近貼文
    func getComment(id: String) -> Observable<[Comment]> //取得留言
    func getForums() -> Observable<[Forum]> //取得話題
    func getPosts(alias: String, limit: String) -> Observable<[Post]> //取得話題貼文
    func getBeforePost(id: String) -> Observable<[Post]> // 取得特定貼文以前貼文
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
    func getRecentPost(limit: String) -> Observable<[Post]> {
        self.posts = [Post]()
        let subject = PublishSubject<[Post]>()
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
                self.posts.append(Post(id: id, title: title, excerpt: excerpt, createdAt: createdAt, commentCount: commentCount, likeCount: likeCount, forumName: forumName, gender: gender, department: department, anonymousSchool: anonymousSchool, anonymousDepartment: anonymousDepartment, school: school, withNickname: withNickname, mediaMeta: mediaMeta))
            }
            subject.onNext(self.posts)
        }, onError: { error in
            subject.onError(error)
        }).disposed(by: disposeBag)
        
        return subject.asObserver()
    }
    func getComment(id: String) -> Observable<[Comment]> {
        self.comments = [Comment]()
        let subject = PublishSubject<[Comment]>()
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
            subject.onNext(self.comments)
        }, onError: { error in
            subject.onError(error)
        }).disposed(by: disposeBag)
        return subject.asObserver()
    }
    func getForums() -> Observable<[Forum]> {
        var forums = [Forum]()
        let subject = PublishSubject<[Forum]>()
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
            subject.onNext(forums)
        }, onError: { error in
            subject.onError(error)
        }).disposed(by: disposeBag)
        return subject.asObserver()
    }
    func getPosts(alias: String, limit: String) -> Observable<[Post]> {
        self.posts = [Post]()
        let subject = PublishSubject<[Post]>()
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
                self.posts.append(Post(id: id, title: title, excerpt: excerpt, createdAt: createdAt, commentCount: commentCount, likeCount: likeCount, forumName: forumName, gender: gender, department: department, anonymousSchool: anonymousSchool, anonymousDepartment: anonymousDepartment, school: school, withNickname: withNickname, mediaMeta: mediaMeta))
            }
            self.getBeforePost(id: self.posts[self.posts.count - 1].id).subscribe(onNext: { posts in
                self.posts += posts
                self.getBeforePost(id: self.posts[self.posts.count - 1].id).subscribe(onNext: { posts in
                    self.posts += posts
                    self.getBeforePost(id: self.posts[self.posts.count - 1].id).subscribe(onNext: { posts in
                        self.posts += posts
                        self.getBeforePost(id: self.posts[self.posts.count - 1].id).subscribe(onNext: { posts in
                            self.posts += posts
                            self.getBeforePost(id: self.posts[self.posts.count - 1].id).subscribe(onNext: { posts in
                                self.posts += posts
                                self.getBeforePost(id: self.posts[self.posts.count - 1].id).subscribe(onNext: { posts in
                                    self.posts += posts
                                    self.getBeforePost(id: self.posts[self.posts.count - 1].id).subscribe(onNext: { posts in
                                        self.posts += posts
                                        self.getBeforePost(id: self.posts[self.posts.count - 1].id).subscribe(onNext: { posts in
                                                        self.posts += posts
                                                        subject.onNext(self.posts)
                                        }).disposed(by: self.disposeBag)
                                    }).disposed(by: self.disposeBag)
                                }).disposed(by: self.disposeBag)
                            }).disposed(by: self.disposeBag)
                        }).disposed(by: self.disposeBag)
                    }).disposed(by: self.disposeBag)
                }).disposed(by: self.disposeBag)
            }).disposed(by: self.disposeBag)
        }, onError: { error in
            subject.onError(error)
        }).disposed(by: disposeBag)
        
        return subject.asObserver()
    }
    func getBeforePost(id: String) -> Observable<[Post]> {
        var posts = [Post]()
        let subject = PublishSubject<[Post]>()
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
                posts.append(Post(id: id, title: title, excerpt: excerpt, createdAt: createdAt, commentCount: commentCount, likeCount: likeCount, forumName: forumName, gender: gender, department: department, anonymousSchool: anonymousSchool, anonymousDepartment: anonymousDepartment, school: school, withNickname: withNickname, mediaMeta: mediaMeta))
            }
            subject.onNext(posts)
        }, onError: { error in
            subject.onError(error)
        }).disposed(by: disposeBag)
        
        return subject.asObserver()
    }
}
