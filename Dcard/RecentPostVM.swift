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
    func getRecentPost()
    func getWhysoserious()
}
class RecentPostVM {
    private let _recentPost = PublishSubject<[Post]>()
    private let _whysoserious = PublishSubject<[Post]>()
    private let postRepository: PostRepositoryInterface
    private let disposeBag = DisposeBag()
    
    init(postRepository: PostRepositoryInterface = PostRepository.shared) {
        self.postRepository = postRepository
    }
}
extension RecentPostVM: RecentPostInterface {
    var whysoserious: PublishSubject<[Post]> {
        return _whysoserious
    }
    var recentPost: PublishSubject<[Post]> {
        return _recentPost
    }
    func getRecentPost() {
        postRepository.getRecentPost(limit: 10).subscribe(onNext: { post in
            self._recentPost.onNext(post)
        }, onError: { error in
            self._recentPost.onError(error)
            }).disposed(by: disposeBag)
    }
    func getWhysoserious() {
        postRepository.getWhysoserious(limit: 100).subscribe(onNext: { post in
            self._whysoserious.onNext(post)
        }, onError: { error in
            self._whysoserious.onError(error)
            }).disposed(by: disposeBag)
    }
}
