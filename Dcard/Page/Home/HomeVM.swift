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
    //取得最近貼文
//    var recentPostSubject: PublishSubject<FirebaseResult<[Post]>> { get }
//    func getRecentPost()
    //取得話題貼文
    var postsSubject: PublishSubject<FirebaseResult<[Post]>> { get }
    func getPosts(alias: String)
    //取得留言
    var commentSubject: PublishSubject<FirebaseResult<[Comment]>> { get }
    func getComment(post: Post)
    //取得話題
    var forumsSubject: PublishSubject<FirebaseResult<[Forum]>> { get }
    func getForums()
    //取得使用者資訊
    var userDataSubject: PublishSubject<FirebaseResult<User>> { get }
    func getUserData(uid: String)
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
    
    init(loginFirebase: LoginFirebaseInterface = LoginFirebase.shared, postRepository: PostRepositoryInterface = PostRepository.shared) {
        self.postRepository = postRepository
        self.loginFirebase = loginFirebase
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
    func getPosts(alias: String) {
        self.postRepository.getPosts(alias: alias, limit: "100").subscribe(onNext: { result in
            self.postsSubject.onNext(result)
        }, onError: { error in
            self.postsSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    func getUserData(uid: String) {
        self.loginFirebase.getUserData(uid: uid).subscribe(onNext: { result in
            self.userDataSubject.onNext(result)
        }, onError: { error in
            self.userDataSubject.onError(error)
            }).disposed(by: disposeBag)
    }
}
