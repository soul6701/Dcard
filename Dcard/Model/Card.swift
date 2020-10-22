//
//  Card.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/5.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation

public struct Card {
    
    public var id = ""
    public var post: [Post] = []
    public var name: String = ""
    public var photo: String = ""
    public var sex: String = ""
    public var introduce: String = ""
    public var country: String = ""
    public var school: String = ""
    public var department: String = ""
    public var article: String = ""
    public var birthday: String = ""
    public var love: String = ""
    public var fans: Int = 0
    public var favariteCatolog: [FavariteCatolog] = {
        var list = [FavariteCatolog]()
        (0...20).forEach { (_) in
            list.append(FavariteCatolog())
        }
        return list
    }()
}
