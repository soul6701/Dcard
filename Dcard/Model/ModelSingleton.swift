//
//  ModelSingleton.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/5.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import UIKit

protocol ModelSingletonInterface {
    //卡片
    var card: [Card] { get }
    func setCard(_ cards: [Card])
    //使用者所有資訊
    var userConfig: UserConfig { get }
    func setUserConfig(_ config: UserConfig)
    //偏好設定
    var preference: Preference { get }
    func setPreference(_ preference: Preference)
    //看板
    var forum: [Forum] { get }
    func setForum(_ forum: [Forum])
    //卡稱
    var userCard: Card { get }
    func setUserCard(_ userCard: Card)
    //收藏清單
    var favorite: [Favorite] { get }
    func setFavoriteList(_ favorite: [Favorite])
    //貼文
    var post: [Post] { get }
    func setPostList(_ post: [Post])
    //留言
    var comment: [Comment] { get }
    func setCommentList(_ comment: [Comment])
    //表情
    var mood: Mood { get }
    func setMood(_ mood: Mood)
}
public class ModelSingleton: ModelSingletonInterface {
    public static let shared = ModelSingleton()
    private(set) public var card: [Card] = []
    private(set) public var userConfig: UserConfig = UserConfig(user: User(), cardmode: 0)
    private(set) public var preference: Preference = Preference()
    private(set) public var forum: [Forum] = []
    private(set) public var userCard: Card = Card()
    private(set) public var favorite: [Favorite] = []
    private(set) public var post: [Post] = []
    private(set) public var comment: [Comment] = []
    private(set) public var mood: Mood = Mood()
    
    public var allFavoritePostID: [String] {
        var allPostIDList = [String]()
        ModelSingleton.shared.favorite.filter { !$0.title.isEmpty }.map { return $0.postIDList }.forEach { (postIDList) in
            allPostIDList += postIDList
        }
        let notSortedIDList = ModelSingleton.shared.favorite.first(where: { return $0.title.isEmpty })?.postIDList ?? []
        return allPostIDList + notSortedIDList
    }
    
    public func setCard(_ cards: [Card]) {
        self.card = cards
    }
    func setUserConfig(_ config: UserConfig) {
        self.userConfig = config
    }
    func setPreference(_ preference: Preference) {
        self.preference = preference
    }
    func setForum(_ forum: [Forum]) {
        self.forum = forum
    }
    func setUserCard(_ userCard: Card) {
        self.userCard = userCard
    }
    func setFavoriteList(_ favorite: [Favorite]) {
        self.favorite = favorite
    }
    func setPostList(_ post: [Post]) {
        self.post = post
    }
    func setCommentList(_ comment: [Comment]) {
        self.comment = comment
    }
    func setMood(_ mood: Mood) {
        self.mood = mood
    }
}
