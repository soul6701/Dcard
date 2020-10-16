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
    public var newReply: Int = 0
    public var getMood: Bool = false
    public var getLiked: Bool = false
    public var getFollowed: Bool = false
    public var newMail: Bool = false
    //顯示主題
    public var showTheme: Int = 0
    //自動播放影片
    public var autoPlayVedio: Int = 0
    //TouchID
    public var touchIDOn: Bool = false
    
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
}
