//
//  ModelSingleton.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/5.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import UIKit

protocol ModelSingletonInterface {
    //卡片
    var card: [Card] { get }
    func setCard(_ cards: [Card])
    //使用者所有資訊
    var userConfig: UserConfig { get }
    func setUserConfig(_ config: UserConfig)
    //偏好設定
    var preference: Preference { get }
    func setPreference(_ preference: Preference)
    //看板
    var forum: [Forum] { get }
    func setForum(_ forum: [Forum])
    //卡稱
    var userCard: Card { get }
    func setUserCard(_ userCard: Card)
    
}
public class ModelSingleton: ModelSingletonInterface {
    public static let shared = ModelSingleton()
    private(set) public var card = [Card]()
    private(set) public var userConfig = UserConfig(user: User(), cardmode: 0)
    private(set) public var preference = Preference()
    private(set) public var forum = [Forum]()
    private(set) public var userCard = Card()
    
    public func setCard(_ cards: [Card]) {
        self.card = cards
    }
    func setUserConfig(_ config: UserConfig) {
        self.userConfig = config
    }
    func setPreference(_ preference: Preference) {
        self.preference = preference
    }
    func setForum(_ forum: [Forum]) {
        self.forum = forum
    }
    func setUserCard(_ userCard: Card) {
        self.userCard = userCard
    }
}
