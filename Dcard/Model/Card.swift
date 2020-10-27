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
    public var favorite: [Favorite] = {
        var _list = [Favorite]()
        let list = [["我像個殘廢 飛不出你的世界", "借不到一點安慰"], ["雖然暗戀讓人早熟", "也讓人多難過"], ["多麽想告訴你 我好喜歡你", "都怪我控制不了自己"], ["未來的每一步一腳印", "相知相習相依為命"]]
        let _mediaMeta = [[MediaMeta(thumbnail: "https://i1.kknews.cc/SIG=17fh01n/3r580003rr4ps40n960o.jpg", normalizedUrl: "https://i1.kknews.cc/SIG=17fh01n/3r580003rr4ps40n960o.jpg")], [MediaMeta(thumbnail: "https://i1.kknews.cc/SIG=1avg1r2/3r580003rqson1npps7s.jpg", normalizedUrl: "https://i1.kknews.cc/SIG=1avg1r2/3r580003rqson1npps7s.jpg")], [MediaMeta(thumbnail: "https://i1.kknews.cc/SIG=11sbjcv/ctp-vzntr/15341312472962rqp6q4r2q.jpg", normalizedUrl: "https://i1.kknews.cc/SIG=11sbjcv/ctp-vzntr/15341312472962rqp6q4r2q.jpg")], [MediaMeta(thumbnail: "https://i1.kknews.cc/SIG=38pi76/ctp-vzntr/1534131247394rsnss9rr7o.jpg", normalizedUrl: "https://i1.kknews.cc/SIG=38pi76/ctp-vzntr/1534131247394rsnss9rr7o.jpg")]]
        var postList: [Post] {
            var _postList = [Post]()
            (0...7).forEach { (i) in
                _postList.append(Post(id: ["qwert12345", "asdfg12345", "zxcvb12345"].randomElement()!, title: list[i % 4][0], excerpt: list[i % 4][1], createdAt: ["2020-12-31", "2020-09-15"].randomElement()!, commentCount: String((0...5).randomElement()!), likeCount: String((0...5).randomElement()!), forumName: ["廢文", "NBA", "穿搭", "寵物"].randomElement()!, gender: ["F", "M"].randomElement()!, department: ["神奇寶貝研究系", "愛哩愛尬沒系", "機械工程系", "資訊工程系", "肥宅養成系", "愛丟卡慘系"].randomElement()!, anonymousSchool: Bool.random(), anonymousDepartment: Bool.random(), school: "", withNickname: Bool.random(), mediaMeta: _mediaMeta[i % 4]))
            }
            return _postList
        }
        var random = Int.random(in: 1...10)
        (0...random).forEach { (_) in
            _list.append(Favorite(photo: "", title: ["居家", "笑話", "美食", "工作", "狗狗"].randomElement()!, posts: postList))
        }
        return _list
    }()
    public var comment: [Comment] = {
        var random = Int.random(in: 1...10)
        var list = [Comment]()
        (0...random).forEach { (_) in
            list.append(Comment())
        }
        return list
    }()
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
