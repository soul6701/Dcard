//
//  Card.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/5.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import UIKit

public struct Card {
    
    public var uid = ""
    public var id = ""
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
    public var followCard: [FollowCard] = []
    public var friendCard: [String] = []
    public var beKeeped = Int.random(in: 0...10000)
    public var beReplyed = Int.random(in: 0...10000)
    public var getHeart = Int.random(in: 0...10000)
    public var getMood: Int {
        return mood.angry + mood.cry + mood.haha + mood.heart + mood.respect + mood.surprise
    }
    public var mood: Mood = Mood()
    
    public var favoritePosts: [String] = []
    public var lovePosts: [String] = []
}
