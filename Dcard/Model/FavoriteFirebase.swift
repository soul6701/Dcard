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
    func addFavoriteList(listName: String, post: [(id: String, coverImage: String)]) -> Observable<FirebaseResult<Bool>>
    ///移除收藏清單
    func removeFavoriteList(listName: String) -> Observable<FirebaseResult<Bool>>
    ///更改收藏清單名字
    func updateFavoriteList(oldListName: String, newListName: String) -> Observable<FirebaseResult<Bool>>
    ///移除收藏清單貼文
    func removePostFromFavoriteList(postID: String) -> Observable<FirebaseResult<Bool>>
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
                    guard key != "notSorted" else {
                        let notSortedPostList: [String] = dir[key] as! [String]
                        favoriteList.append(Favorite(title: "", createAt: "", postIDList: notSortedPostList, coverImage: [String]()))
                        return
                    }
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
                var oldFavoriteList = ModelSingleton.shared.favorite
                let newFavorite = Favorite(title: listName, createAt: Date.getCurrentDateString(true), postIDList: [String](), coverImage: [String]())
                oldFavoriteList.append(newFavorite)
                ModelSingleton.shared.setFavoriteList(oldFavoriteList)
                subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: ["new": newFavorite]))
            }
        }
        return subject
    }
    // MARK: - 加入收藏清單
    func addFavoriteList(listName: String, post: [(id: String, coverImage: String)]) -> Observable<FirebaseResult<Bool>> {
        
        let idList: [String] = post.map { (id, _) -> String in
            return id
        }
        let coverImageList: [String] = post.map { (_, coverImage) -> String in
            return coverImage
        }
        let subject = PublishSubject<FirebaseResult<Bool>>()
        
        var notCatologPostIDList = [String]()
        // 從未分類清單中移除
        post.forEach { (post) in
            if let index = ModelSingleton.shared.favorite.firstIndex(where: { return $0.title == ""}), ModelSingleton.shared.favorite[index].postIDList.contains(post.id) {
                var favorite = ModelSingleton.shared.favorite
                favorite[index].postIDList = favorite[index].postIDList.filter( { return $0 == post.id})
                ModelSingleton.shared.setFavoriteList(favorite)
                notCatologPostIDList.append(post.id)
            }
        }
        
        let setter: [String:Any] = !listName.isEmpty ? ["\(listName).post": FieldValue.arrayUnion(idList), "\(listName).coverImage": FieldValue.arrayUnion(coverImageList), "notSorted": FieldValue.arrayRemove(notCatologPostIDList)] :
            ["notSorted": FieldValue.arrayUnion(idList)]
        FirebaseManager.shared.db.collection(DatabaseName.favoritePost.rawValue).document(ModelSingleton.shared.userConfig.user.uid).updateData(setter) { (error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            } else {
                let setter: [String:Any] = ["favoritePosts": FieldValue.arrayUnion(idList)]
                FirebaseManager.shared.db.collection(DatabaseName.card.rawValue).document(ModelSingleton.shared.userConfig.user.uid).updateData(setter) { (error) in
                    if let error = error {
                        NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                        subject.onError(error)
                    } else {
                        var oldFavoriteList = ModelSingleton.shared.favorite
                        if let index = oldFavoriteList.firstIndex(where: { $0.title == listName }) {
                            idList.forEach { (id) in
                                oldFavoriteList[index].postIDList.append(id)
                            }
                            coverImageList.forEach { (coverImage) in
                                oldFavoriteList[index].coverImage.append(coverImage)
                            }
                            ModelSingleton.shared.setFavoriteList(oldFavoriteList)
                            subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: nil))
                        }
                    }
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
    // MARK: - 移除收藏清單貼文
    func removePostFromFavoriteList(postID: String) -> Observable<FirebaseResult<Bool>> {
        let subject = PublishSubject<FirebaseResult<Bool>>()
        
        FirebaseManager.shared.db.collection(DatabaseName.favoritePost.rawValue).document(ModelSingleton.shared.userConfig.user.uid).getDocument { (querySnapshot, error) in
            if let error = error {
                NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                subject.onError(error)
            }
            if let querySnapshot = querySnapshot, let dir = querySnapshot.data() {
                for key in dir.keys {
                    if key != "notSorted" {
                        if let favorite = dir[key] as? [String:Any], let index = (favorite["post"] as! [String]).firstIndex(of: postID) {
                            let coverImage = (favorite["coverImage"] as! [String])[index]
                            FirebaseManager.shared.db.collection(DatabaseName.favoritePost.rawValue).document(ModelSingleton.shared.userConfig.user.uid).updateData(["\(key).post": FieldValue.arrayRemove([postID]), "\(key).coverImage": FieldValue.arrayRemove([coverImage])]) { (error) in
                                if let error = error {
                                    NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                                    subject.onError(error)
                                } else {
                                    var oldFavoriteList = ModelSingleton.shared.favorite
                                    if let index = oldFavoriteList.firstIndex (where: { $0.title == key }) {
                                        oldFavoriteList[index].postIDList.removeAll(where: { return $0 == postID })
                                        oldFavoriteList[index].coverImage.removeAll(where: { return $0 == coverImage })
                                        ModelSingleton.shared.setFavoriteList(oldFavoriteList)
                                        subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: nil))
                                    }
                                }
                            }
                        }
                    } else {
                        if let notSortedIDList = dir[key] as? [String], notSortedIDList.contains(postID) {
                            FirebaseManager.shared.db.collection(DatabaseName.favoritePost.rawValue).document(ModelSingleton.shared.userConfig.user.uid).updateData([key: FieldValue.arrayRemove([postID])]) { (error) in
                                if let error = error {
                                    NSLog("🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶\(error.localizedDescription)🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶")
                                    subject.onError(error)
                                } else {
                                    var oldFavoriteList = ModelSingleton.shared.favorite
                                    if let index = oldFavoriteList.firstIndex (where: { $0.title == "" }) {
                                        oldFavoriteList[index].postIDList.removeAll(where: { return $0 == postID })
                                        ModelSingleton.shared.setFavoriteList(oldFavoriteList)
                                        subject.onNext(FirebaseResult<Bool>(data: true, errorMessage: nil, sender: nil))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return subject
    }
}
