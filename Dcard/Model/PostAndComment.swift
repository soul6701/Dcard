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
    var id: String = ""
    var title: String = ""
    var excerpt: String = ""
    var createdAt: String = ""
    var commentCount: String = ""
    var likeCount: String = ""
    var forumAlias: String = ""
    var forumName: String = ""
    var gender: String = ""
    var department: String = ""
    var anonymousSchool: Bool = false
    var anonymousDepartment: Bool = false
    var school: String = ""
    var withNickname: Bool = false
    var mediaMeta: [MediaMeta] = []
    var host: String = ""
    var hot: Bool = false
}
public struct Comment {
    var id: String = ""
    var anonymous: Bool = false
    var content: String = ""
    var createdAt: String = ""
    var floor: Int = 0
    var likeCount: Int = 0
    var gender: String = ""
    var department: String = ""
    var school: String = ""
    var withNickname: Bool = false
    var host: Bool = false
    var mediaMeta: [MediaMeta] = []
}
