//
//  RecentPostVM.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/6/27.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol HomeVMInterface {
    ///取得最近貼文
//    var recentPostSubject: PublishSubject<FirebaseResult<[Post]>> { get }
//    func getRecentPost()
    ///取得話題貼文
    func getPosts(alias: String, fromFireBase: Bool)
    var postsSubject: PublishSubject<FirebaseResult<[Post]>> { get }
    ///取得留言
    func getComment(post: Post)
    var commentSubject: PublishSubject<FirebaseResult<[Comment]>> { get }
    ///取得話題
    func getForums()
    var forumsSubject: PublishSubject<FirebaseResult<[Forum]>> { get }
    ///取得使用者資訊
    func getUserData(uid: String)
    var userDataSubject: PublishSubject<FirebaseResult<User>> { get }
}
class HomeVM {
//    private(set) var recentPostSubject = PublishSubject<FirebaseResult<[Post]>>()
    private(set) var commentSubject = PublishSubject<FirebaseResult<[Comment]>>()
    private(set) var forumsSubject = PublishSubject<FirebaseResult<[Forum]>>()
    private(set) var postsSubject = PublishSubject<FirebaseResult<[Post]>>()
    private(set) var userDataSubject = PublishSubject<FirebaseResult<User>>()
    private(set) var disposeBag = DisposeBag()
    
    private var postRepository: PostRepositoryInterface
    private var loginFirebase: LoginFirebaseInterface
    private var postFirebase: PostFirebaseInterface
    
    init(loginFirebase: LoginFirebaseInterface = LoginFirebase.shared, postRepository: PostRepositoryInterface = PostRepository.shared, postFirebase: PostFirebaseInterface = PostFirebase.shared) {
        self.postRepository = postRepository
        self.loginFirebase = loginFirebase
        self.postFirebase = postFirebase
    }
}
extension HomeVM: HomeVMInterface {
    
//    func getRecentPost() {
//        self.postRepository.getRecentPost(limit: "10").subscribe(onNext: { posts in
//            self.recentPostSubject.onNext(posts)
//        }, onError: { error in
//            self.recentPostSubject.onError(error)
//            }).disposed(by: disposeBag)
//    }
    func getComment(post: Post) {
        self.postRepository.getComment(id: post.id).subscribe(onNext: { result in
            self.commentSubject.onNext((result))
        }, onError: { error in
        self.commentSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    func getForums() {
        self.postRepository.getForums().subscribe(onNext: { result in
            self.forumsSubject.onNext(result)
        }, onError: { error in
        self.forumsSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    func getPosts(alias: String, fromFireBase: Bool) {
        if fromFireBase {
            self.postFirebase.getPosts(alias: alias, limit: "100").subscribe(onNext: { (result) in
                self.postsSubject.onNext(result)
            }, onError: { (error) in
                self.postsSubject.onError(error)
            }).disposed(by: self.disposeBag)
        } else {
            self.postRepository.getPosts(alias: alias, limit: "100").subscribe(onNext: { result in
                self.postsSubject.onNext(result)
            }, onError: { error in
                self.postsSubject.onError(error)
                }).disposed(by: disposeBag)
        }
    }
    func getUserData(uid: String) {
        self.loginFirebase.getUserData(uid: uid).subscribe(onNext: { result in
            self.userDataSubject.onNext(result)
        }, onError: { error in
            self.userDataSubject.onError(error)
            }).disposed(by: disposeBag)
    }
}
