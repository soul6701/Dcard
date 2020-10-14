//
//  DbManager+Preference.swift
//  Dcard
//
//  Created by admin on 2020/10/12.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import SQLite

//偏好資訊
let _preference = Table("Preference")
let _newReply = Expression<Int>("newReply") //0: 關閉 1: 標註我的回應 2: 所有回應
let _getMood = Expression<Bool>("getMood")
let _getLiked = Expression<Bool>("getLiked")
let _getFollowed = Expression<Bool>("getFollowed")
let _newMail = Expression<Bool>("newMail")
let _showTheme = Expression<Int>("showTheme") //0: 根據系統設定 1: 深色模式 2: 淺色模式
let _autoPlayVedio = Expression<Int>("autoPlayVedio") //0: 開啟 1: 關閉 2: 僅 Wi-Fi

extension DbManager {

    func createPreferenceTable() {
        do {
            try db.run(_preference.create(ifNotExists: true) { tb in
                tb.column(_newReply)
                tb.column(_getMood)
                tb.column(_getLiked)
                tb.column(_getFollowed)
                tb.column(_newMail)
                tb.column(_showTheme)
                tb.column(_autoPlayVedio)
                print("創建偏好設定資料表 成功")
            })
        } catch {
            print("創建偏好設定資料表 失敗")
        }
    }
    func initPreference() {
        do {
            try db?.run(_preference.insert(_newReply <- 0, _getMood <- false, _getLiked <- false, _getFollowed <- false, _newMail <- false, _showTheme <- 0, _autoPlayVedio <- 0))
            print("新增偏好設定資料表 成功")
        } catch {
            print("新增偏好設定資料表 失敗")
        }
    }
    func getPreference() -> Preference {
        var list = [Preference]()
        do {
            for _list in try db.prepare(_preference) {
                list.append(Preference(newReply: _list[_newReply], getMood: _list[_getMood], getLiked: _list[_getLiked], getFollowed: _list[_getFollowed], newMail: _list[_newMail], showTheme: _list[_showTheme], autoPlayVedio: _list[_autoPlayVedio]))
            }
            print("取得偏好設定資料表 成功")
        } catch {
            print("取得偏好設定資料表 失敗")
        }
        return list.first ?? Preference()
    }
    func updatePreference(preference: Preference) {
        do {
            try db.run(_preference.update([_newReply <- preference.newReply, _getMood <- preference.getMood, _getLiked <- preference.getLiked, _getFollowed <- preference.getFollowed, _newMail <- preference.newMail, _showTheme <- preference.showTheme, _autoPlayVedio <- preference.autoPlayVedio]))
            print("更新偏好設定資料表 成功")
        } catch {
            print("更新偏好設定資料表 失敗")
        }
    }
}
