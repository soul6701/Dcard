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
    //創建帳戶
    var ccreartFavoriteListSubject: PublishSubject<Bool> { get }
    func creartFavoriteList(listName: String, post: Post)
}
class PostVM: PostVMInterface {
    private (set) var ccreartFavoriteListSubject = PublishSubject<Bool>()
    
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
}
