//
//  Comment.swift
//  Dcard
//
//  Created by Mason on 2020/11/20.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation

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
