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
}
public class ModelSingleton: ModelSingletonInterface {
    public static let shared = ModelSingleton()
    private(set) var card = [Card]()
    private(set) var userConfig = UserConfig(user: User(), cardmode: 0)
    private(set) var preference = Preference()
    
    public func setCard(_ cards: [Card]) {
        self.card = cards
    }
    func setUserConfig(_ config: UserConfig) {
        self.userConfig = config
    }
    func setPreference(_ preference: Preference) {
        self.preference = preference
    }
}
