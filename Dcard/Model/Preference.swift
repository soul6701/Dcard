//
//  Preference.swift
//  Dcard
//
//  Created by admin on 2020/10/12.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation

public struct Preference {
    //推播通知設定
    var newReply: Int
    var getMood: Bool
    var getLiked: Bool
    var getFollowed: Bool
    var newMail: Bool
    //顯示主題
    var showTheme: Int
    //自動播放影片
    var autoPlayVedio: Int
    
    var themeToString: String {
        switch self.showTheme {
        case 0:
            return "根據系統設定"
        case 1:
            return "深色模式"
        default:
            return "淺色模式"
        }
    }
    var autoPlayVedioToString: String {
        switch self.autoPlayVedio {
        case 0:
            return "開啟"
        case 1:
            return "關閉"
        default:
            return "僅 Wi-Fi"
        }
    }
    public init(newReply: Int = 0, getMood: Bool = false, getLiked: Bool = false, getFollowed: Bool = false, newMail: Bool = false, showTheme: Int = 0, autoPlayVedio: Int = 0) {
        self.newReply = newReply
        self.getMood = getMood
        self.getLiked = getLiked
        self.getFollowed = getFollowed
        self.newMail = newMail
        self.showTheme = showTheme
        self.autoPlayVedio = autoPlayVedio
    }
}
