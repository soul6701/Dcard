//
//  PostVM.swift
//  Dcard
//
//  Created by Mason on 2020/10/29.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Firebase
import UIKit
import RxSwift
import RxCocoa

protocol PostVMInterface {
    ///創建帳戶
    var ccreartFavoriteListSubject: PublishSubject<Bool> { get }
    func creartFavoriteList(listName: String, post: Post)
    ///取得使用者貼文
    var getPostInfoSubject: PublishSubject<FirebaseResult<[Post]>> { get }
    func getPostInfo(uid: String)
}
class PostVM: PostVMInterface {
    private(set) var ccreartFavoriteListSubject = PublishSubject<Bool>()
    private(set) var getPostInfoSubject = PublishSubject<FirebaseResult<[Post]>>()
    
    private var postFirebase: PostFirebaseInterface
    private let disposeBag = DisposeBag()
    
    init(postFirebase: PostFirebaseInterface = PostFirebase.shared) {
        self.postFirebase = postFirebase
    }
}
extension PostVM {
    func creartFavoriteList(listName: String, post: Post) {
        self.postFirebase.creartFavoriteList(listName: listName, post: post).subscribe(onNext: { (result) in
            self.ccreartFavoriteListSubject.onNext(result)
        }, onError: { (error) in
            self.ccreartFavoriteListSubject.onError(error)
        }).disposed(by: self.disposeBag)
    }
    func getPostInfo(uid: String) {
        self.postFirebase.getPostInfo(uid: uid).subscribe(onNext: { (result) in
                self.getPostInfoSubject.onNext(result)
            }, onError: { (error) in
                self.getPostInfoSubject.onError(error)
            }).disposed(by: self.disposeBag)
        }
}
