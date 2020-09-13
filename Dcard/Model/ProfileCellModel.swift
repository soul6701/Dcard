//
//  ProfileCellModel.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/13.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation

// MARK: - 個人資料列表
//我的收藏
public struct Favorite {
    
    public var listName: String = ""
    public var post: [Post] = []
    
}
//我追蹤的話題
public struct FollowIssue {
    
    public var listName: String = ""
    public var postCount: Int = 0
    public var followCount: Int = 0
    public var notifyMode: Int = 0 //0: 開啟新文章通知 1: 開啟個人化文章通知 2: 關閉全部文章通知
    public var isFollowing: Bool = true
}
//我追蹤的卡稱
public struct FollowCard {

    public var card: CardAlias
    public var notifyMode: Int = 0 //0: 開啟新文章通知 1: 開啟個人化文章通知 2: 關閉全部文章通知
    public var isFollowing: Bool = true
    public var isNew: Bool = false
}
//我的信件
public struct Mail {
    
    public var card: Card = Card()
    public var message: [Message] = []
    public var isNew: Bool = false
}

// MARK: - 共用
//卡稱
public struct CardAlias {

    public var name: String = ""
    public var id = ""
    public var post: [Post] = []
}
//訊息
public struct Message {
    
    public var user: Bool = false //0: 我 1: 對方
    public var text: String = ""
    public var date: Date = Date()
}
