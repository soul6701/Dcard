//
//  Forum.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/7/17.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation

public struct Forum {
    let alias: String
    let name: String
    let logo: String
    let postCount: Int //最近30天發文數
    
    public init(alias: String = "", name: String = "", logo: String = "", postCount: Int = 0) {
        self.alias = alias
        self.name = name
        self.logo = logo
        self.postCount = postCount
    }
}
