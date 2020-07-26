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
    func getRecentPost()
    func getComment(list: [Post], index: Int)
    func getForums()
    func getPosts(alias: String)
}
class HomeVM {
    private let _recentPostSubject = PublishSubject<[Post]>()
    private let _postsSubject = PublishSubject<[Post]>()
    private let _commentSubject = PublishSubject<([Comment], Int)>()
    private let _forumsSubject = PublishSubject<[Forum]>()
    private let postRepository = PostRepository.shared
    private let disposeBag = DisposeBag()
}
extension HomeVM: RecentPostInterface {
    var postsSubject: PublishSubject<[Post]> {
        return _postsSubject
    }
    var recentPostSubject: PublishSubject<[Post]> {
        return _recentPostSubject
    }
    var commentSubject: PublishSubject<([Comment], Int)> {
        return _commentSubject
    }
    var forumsSubject: PublishSubject<[Forum]> {
        return _forumsSubject
    }
    func getRecentPost() {
        postRepository.getRecentPost(limit: "10").subscribe(onNext: { posts in
            self._recentPostSubject.onNext(posts)
        }, onError: { error in
            self._recentPostSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    func getComment(list: [Post], index: Int) {
        postRepository.getComment(id: list[index].id).subscribe(onNext: { comments in
            self._commentSubject.onNext((comments, index))
        }, onError: { error in
        self._commentSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    func getForums() {
        postRepository.getForums().subscribe(onNext: { forums in
            self._forumsSubject.onNext(forums)
        }, onError: { error in
        self._forumsSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    func getPosts(alias: String) {
        postRepository.getPosts(alias: alias, limit: "100").subscribe(onNext: { posts in
            self._postsSubject.onNext(posts)
        }, onError: { error in
            self._postsSubject.onError(error)
            }).disposed(by: disposeBag)
    }
}
