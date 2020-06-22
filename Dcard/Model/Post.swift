//
//  Post.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/6/17.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

public struct Post {
    let id: Int
    let title: String
    let excerpt: String
    let createdAt: String
    let commentCount: Int
    let likeCount: Int
    let forumName: String
    let gender: String
    let school: String?
    let mediaMeta: [MediaMeta]
    
    init(id: Int, title: String, excerpt: String, createdAt: String, commentCount: Int, likeCount: Int, forumName: String, gender: String, school: String, mediaMeta: [MediaMeta]) {
        self.id = id
        self.title = title
        self.excerpt = excerpt
        self.createdAt = createdAt
        self.commentCount = commentCount
        self.likeCount = likeCount
        self.forumName = forumName
        self.gender = gender
        self.school = school
        self.mediaMeta = [MediaMeta]()
    }
}
public struct MediaMeta {
    let thumbnail: String
    let normalizedUrl: String
}
