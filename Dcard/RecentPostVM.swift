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
    var recentPost: PublishSubject<[Post]> { get }
    var whysoserious: PublishSubject<[Post]> { get }
    var comment: PublishSubject<([Comment], Int)> { get }
    func getRecentPost()
    func getWhysoserious()
    func getComment(list: [Post], index: Int)
}
class HomeVM {
    private let _recentPost = PublishSubject<[Post]>()
    private let _whysoserious = PublishSubject<[Post]>()
    private let _comment = PublishSubject<([Comment], Int)>()
    private let postRepository = PostRepository.shared
    private let disposeBag = DisposeBag()
}
extension HomeVM: RecentPostInterface {
    var whysoserious: PublishSubject<[Post]> {
        return _whysoserious
    }
    var recentPost: PublishSubject<[Post]> {
        return _recentPost
    }
    var comment: PublishSubject<([Comment], Int)> {
        return _comment
    }
    func getRecentPost() {
        postRepository.getRecentPost(limit: "10").subscribe(onNext: { posts in
            self._recentPost.onNext(posts)
        }, onError: { error in
            self._recentPost.onError(error)
            }).disposed(by: disposeBag)
    }
    func getWhysoserious() {
        postRepository.getWhysoserious(limit: "100").subscribe(onNext: { posts in
            self._whysoserious.onNext(posts)
        }, onError: { error in
            self._whysoserious.onError(error)
            }).disposed(by: disposeBag)
    }
    func getComment(list: [Post], index: Int) {
        postRepository.getComment(id: list[index].id).subscribe(onNext: { comments in
            self._comment.onNext((comments, index))
        }, onError: { error in
        self._comment.onError(error)
            }).disposed(by: disposeBag)
    }
}
