//
//  Post.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/6/17.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

public struct MediaMeta {
    let thumbnail: String
    let normalizedUrl: String
}
public struct Post {
    let id: String
    let title: String
    let excerpt: String
    let createdAt: String
    let commentCount: String
    let likeCount: String
    let forumName: String
    let gender: String
    let department: String
    let anonymousSchool: Bool
    let anonymousDepartment: Bool
    let school: String
    let withNickname: Bool
    let mediaMeta: [MediaMeta]
    
    init(id: String, title: String, excerpt: String, createdAt: String, commentCount: String, likeCount: String, forumName: String, gender: String, school: String, mediaMeta: [MediaMeta], department: String, anonymousSchool: Bool, anonymousDepartment: Bool, withNickname: Bool) {
        self.id = id
        self.title = title
        self.excerpt = excerpt
        self.createdAt = createdAt
        self.commentCount = commentCount
        self.likeCount = likeCount
        self.forumName = forumName
        self.gender = gender
        self.school = school
        self.mediaMeta = mediaMeta
        self.department = department
        self.anonymousSchool = anonymousSchool
        self.anonymousDepartment = anonymousDepartment
        self.withNickname = withNickname
    }
}
public struct Comment {
    let id: String
    let anonymous: Bool
    let content: String
    let createdAt: String
    let floor: Int
    let likeCount: Int
    let gender: String
    let department: String
    let school: String
    let withNickname: Bool
    let host: Bool
    let mediaMeta: [MediaMeta]
    
    init(id: String, anonymous: Bool, content: String, createdAt: String, floor: Int, likeCount: Int, gender: String, school: String, mediaMeta: [MediaMeta], department: String, host: Bool, withNickname: Bool) {
        self.id = id
        self.anonymous = anonymous
        self.content = content
        self.createdAt = createdAt
        self.floor = floor
        self.likeCount = likeCount
        self.gender = gender
        self.school = school
        self.mediaMeta = mediaMeta
        self.department = department
        self.host = host
        self.withNickname = withNickname
    }
}
