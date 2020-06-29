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
    func getRecentPost(limit: Int) -> Observable<[Post]>
    func getWhysoserious(limit: Int) -> Observable<[Post]>
}
class PostRepository {
    public static let shared = PostRepository()
    private let disposeBag = DisposeBag()
    
    let apiManager: APIManager
    init(apiManager: APIManager = APIManager.shared) {
        self.apiManager = apiManager
    }
}
extension PostRepository: PostRepositoryInterface {
    func getRecentPost(limit: Int) -> Observable<[Post]> {
        let subject = PublishSubject<[Post]>()
        APIManager.shared.getPost(limit: limit).subscribe(onNext: { result in
            guard let count = result.json?.arrayObject?.count else {
                print("JSON分析錯誤")
                return
            }
            var posts = [Post]()
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
                var mediaMeta = [MediaMeta]()
                let list = result.json![index]["mediaMeta"].arrayValue
                for mediaMetaJson in list {
                    mediaMeta.append(MediaMeta(thumbnail: mediaMetaJson["thumbnail"].stringValue, normalizedUrl: mediaMetaJson["normalizedUrl"].stringValue))
                }
                posts.append(Post(id: id, title: title, excerpt: excerpt, createdAt: createdAt, commentCount: commentCount, likeCount: likeCount, forumName: forumName, gender: gender, school: school, mediaMeta: mediaMeta))
            }
            subject.onNext(posts)
        }, onError: { error in
            subject.onError(error)
        }).disposed(by: disposeBag)
        
        return subject.asObserver()
    }
    func getWhysoserious(limit: Int) -> Observable<[Post]> {
        let subject = PublishSubject<[Post]>()
        APIManager.shared.getWhysoserious(limit: limit).subscribe(onNext: { result in
            guard let count = result.json?.arrayObject?.count else {
                print("JSON分析錯誤")
                return
            }
            var posts = [Post]()
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
                var mediaMeta = [MediaMeta]()
                let list = result.json![index]["mediaMeta"].arrayValue
                for mediaMetaJson in list {
                    mediaMeta.append(MediaMeta(thumbnail: mediaMetaJson["thumbnail"].stringValue, normalizedUrl: mediaMetaJson["normalizedUrl"].stringValue))
                }
                posts.append(Post(id: id, title: title, excerpt: excerpt, createdAt: createdAt, commentCount: commentCount, likeCount: likeCount, forumName: forumName, gender: gender, school: school, mediaMeta: mediaMeta))
            }
            subject.onNext(posts)
        }, onError: { error in
            subject.onError(error)
        }).disposed(by: disposeBag)
        
        return subject.asObserver()
    }
}
