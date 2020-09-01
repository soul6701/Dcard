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

protocol RecentPostInterface {
    var recentPostSubject: PublishSubject<[Post]> { get } //取得最近貼文
    var postsSubject: PublishSubject<[Post]> { get } //取得話題貼文
    var commentSubject: PublishSubject<([Comment], Int)> { get } //取得留言
    var forumsSubject: PublishSubject<[Forum]> { get } //取得話題
    var userDataSubject: PublishSubject<User> { get } //取得使用者資訊
    
    func getRecentPost()
    func getComment(list: [Post], index: Int)
    func getForums()
    func getPosts(alias: String)
    func getUserData(uid: String)
}
class HomeVM {
    private(set) var recentPostSubject = PublishSubject<[Post]>()
    private(set) var commentSubject = PublishSubject<([Comment], Int)>()
    private(set) var forumsSubject = PublishSubject<[Forum]>()
    private(set) var postsSubject = PublishSubject<[Post]>()
    private(set) var userDataSubject = PublishSubject<User>()
    private(set) var disposeBag = DisposeBag()
    
    private var postRepository = PostRepository.shared
    private var userFirebase = UserFirebase.shared
    
}
extension HomeVM: RecentPostInterface {
    
    func getRecentPost() {
        postRepository.getRecentPost(limit: "10").subscribe(onNext: { posts in
            self.recentPostSubject.onNext(posts)
        }, onError: { error in
            self.recentPostSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    func getComment(list: [Post], index: Int) {
        postRepository.getComment(id: list[index].id).subscribe(onNext: { comments in
            self.commentSubject.onNext((comments, index))
        }, onError: { error in
        self.commentSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    func getForums() {
        postRepository.getForums().subscribe(onNext: { forums in
            self.forumsSubject.onNext(forums)
        }, onError: { error in
        self.forumsSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    func getPosts(alias: String) {
        postRepository.getPosts(alias: alias, limit: "100").subscribe(onNext: { posts in
            self.postsSubject.onNext(posts)
        }, onError: { error in
            self.postsSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    func getUserData(uid: String) {
        userFirebase.getUserData(uid: uid).subscribe(onNext: { user in
            self.userDataSubject.onNext(user)
        }, onError: { error in
            self.userDataSubject.onError(error)
            }).disposed(by: disposeBag)
    }
}
