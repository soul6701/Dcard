//
//  ModelSingleton.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/5.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation

protocol ModelSingletonInterface {
    //卡片
    var card: [Card] { get }
    func setCard(cards: [Card])
    //使用者所有資訊
    var userConfig: UserConfig { get }
    func setUserConfig(config: UserConfig)
}
public class ModelSingleton: ModelSingletonInterface {
    public static let shared = ModelSingleton()
    private(set) var card = [Card]()
    private(set) var userConfig = UserConfig(user: User(), cardmode: 0)
    
    public func setCard(cards: [Card]) {
        self.card = cards
    }
    func setUserConfig(config: UserConfig) {
        
    }
}
