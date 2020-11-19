//
//  FavoriteFirebase.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/11/2.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase
import FirebaseFirestore
import FirebaseStorage

protocol FavoriteFirebaseInterface {
    ///取得收藏清單
    func setupFaroriteData() -> Observable<FirebaseResult<Bool>>
    ///添加收藏清單
    func createFavoriteList(listName: String) -> Observable<FirebaseResult<Bool>>
    ///加入收藏清單
    func addFavoriteList(listName: String, postID: String, coverImage: String) -> Observable<FirebaseResult<Bool>>
    ///移除收藏清單
    func removeFavoriteList(listName: String) -> Observable<FirebaseResult<Bool>>
    ///更改收藏清單名字
    func updateFavoriteList(oldListName: String, newListName: String) -> Observable<FirebaseResult<Bool>>
}
public class FavoriteFirebase: FavoriteFirebaseInterface {
    
    public static var shared = FavoriteFirebase()
    private let disposeBag = DisposeBag()
    
    // MARK: - 取得收藏清單
    func setupFaroriteData() -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        var favoriteList = [Favorite]()
        FirebaseManager.shared.db.collection(DatabaseName.favoritePost.rawValue).document(ModelSingleton.shared.userConfig.user.uid).getDocument { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
            }
            if let querySnapshot = querySnapshot, let dir = querySnapshot.data() {
                dir.keys.forEach { (key) in
                    let title: String = key
                    let favoriteDir: [String: Any] = dir[key] as! [String : Any]
                    let createAt: String = favoriteDir["createAt"] as! String
                    let postIDList: [String] = favoriteDir["post"] as! [String]
                    let coverImage: [String] = favoriteDir["coverImage"] as! [String]
                    favoriteList.append(Favorite(title: title, createAt: createAt, postIDList: postIDList, coverImage: coverImage))
                }
                ModelSingleton.shared.setFavoriteList(favoriteList)
                subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: nil))
            } else {
                subject.onNext(FirebaseResult<Bool>(data: false, errorMessage: .login(4), sender: nil))
            }
        }
        return subject
    }
    // MARK: - 添加收藏清單
    func createFavoriteList(listName: String) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        let setter: [String : Any] = [listName : ["createAt" : Date.getCurrentDateString(true), "post" : [String](), "coverImage" : [String]()]]
        FirebaseManager.shared.db.collection(DatabaseName.favoritePost.rawValue).document(ModelSingleton.shared.userConfig.user.uid).setData(setter, merge: true) { (error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                var oldFavorite = ModelSingleton.shared.favorite
                oldFavorite.append(Favorite(title: listName, createAt: Date.getCurrentDateString(true), postIDList: [String](), coverImage: [String]()))
                ModelSingleton.shared.setFavoriteList(oldFavorite)
                subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: nil))
            }
        }
        return subject
    }
    // MARK: - 加入收藏清單
    func addFavoriteList(listName: String, postID: String, coverImage: String) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        
        FirebaseManager.shared.db.collection(DatabaseName.favoritePost.rawValue).document(ModelSingleton.shared.userConfig.user.uid).updateData(["\(listName).post": FieldValue.arrayUnion([postID]), "\(listName).coverImage": FieldValue.arrayUnion([coverImage])]) { (error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                var oldFavoriteList = ModelSingleton.shared.favorite
                if let index = oldFavoriteList.firstIndex(where: { $0.title == listName }) {
                    oldFavoriteList[index].postIDList.append(postID)
                    oldFavoriteList[index].coverImage.append(coverImage)
                    ModelSingleton.shared.setFavoriteList(oldFavoriteList)
                    subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: nil))
                }
            }
        }
        return subject
    }
    // MARK: - 移除收藏清單
    func removeFavoriteList(listName: String) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        
        let setter: [String: Any] = [listName : FieldValue.delete()]
        FirebaseManager.shared.db.collection(DatabaseName.favoritePost.rawValue).document(ModelSingleton.shared.userConfig.user.uid).updateData(setter) { (error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                var oldFavoriteList = ModelSingleton.shared.favorite
                if let index = oldFavoriteList.firstIndex(where: { $0.title == listName }) {
                    oldFavoriteList.remove(at: index)
                    ModelSingleton.shared.setFavoriteList(oldFavoriteList)
                    subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: nil))
                }
            }
        }
        return subject
    }
    // MARK: - 更改收藏清單名字
    func updateFavoriteList(oldListName: String, newListName: String) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        
        guard let copyIndex = (ModelSingleton.shared.favorite.firstIndex { return $0.title == oldListName }) else { return subject }
        let copy = ModelSingleton.shared.favorite[copyIndex]
        let setter: [String: Any] = [newListName : ["createAt" : copy.createAt, "post" : copy.postIDList, "coverImage" : copy.coverImage], oldListName : FieldValue.delete()]
        FirebaseManager.shared.db.collection(DatabaseName.favoritePost.rawValue).document(ModelSingleton.shared.userConfig.user.uid).updateData(setter) { (error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                var oldFavoriteList = ModelSingleton.shared.favorite
                oldFavoriteList.remove(at: copyIndex)
                let newFavorite = Favorite(title: newListName, createAt: copy.createAt, postIDList: copy.postIDList, coverImage: copy.coverImage)
                oldFavoriteList.append(newFavorite)
                ModelSingleton.shared.setFavoriteList(oldFavoriteList)
                subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: nil))
            }
        }
        return subject
    }
}
