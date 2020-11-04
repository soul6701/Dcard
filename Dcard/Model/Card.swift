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
}
public struct Mood {
    public var heart: Int = Int.random(in: 0...10000)
    public var haha: Int = Int.random(in: 0...10000)
    public var angry: Int = 999999
    public var cry: Int = Int.random(in: 0...10000)
    public var surprise: Int = Int.random(in: 0...10000)
    public var respect: Int = Int.random(in: 0...100000)
    
   public var sortedMoods: [(ProfilePostMoodCellMode, Int)] {
        var list = [(ProfilePostMoodCellMode, Int)]()
        list.append((.heart, self.heart))
        list.append((.haha, self.haha))
        list.append((.angry, self.angry))
        list.append((.cry, self.cry))
        list.append((.surprise, self.surprise))
        list.append((.respect, self.respect))
        list.sort { return $0.1 < $1.1 }
        return list
    }
    public var largest: ProfilePostMoodCellMode {
        return self.sortedMoods.last!.0
    }
    public var secondLargest: ProfilePostMoodCellMode {
        return self.sortedMoods[self.sortedMoods.count - 2].0
    }
    
    //計算心情數比例
    public var contrast: Bool {
        let largest = self.sortedMoods.first { return $0.0 == self.largest }!
        let secondLargest = self.sortedMoods.first { return $0.0 == self.secondLargest }!
        let difference = largest.1.findMultipleBaseTen() - secondLargest.1.findMultipleBaseTen()
        return difference >= 1 || difference == 0 && (largest.1 / secondLargest.1 > 2)
    }
    public var scale: [ProfilePostMoodCellMode: CGFloat] {
        return calculateScale(self.contrast ? self.sortedMoods.dropLast() : self.sortedMoods)
    }
    private func calculateScale(_ list: [(ProfilePostMoodCellMode, Int)]) -> [ProfilePostMoodCellMode: CGFloat] {
        var scale = [ProfilePostMoodCellMode: CGFloat]()
        let countList: [Int] = list.map { return $0.1 }
        let total = countList.reduce(0) { return $0 + $1 }
        list.forEach { (mode, count) in
            scale[mode] = CGFloat(Double(count) / Double(total))
        }
        return scale
    }
}
