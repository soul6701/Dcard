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
let _touchIDOn = Expression<Bool>("touchIDOn")

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
                tb.column(_touchIDOn)
                print("創建偏好設定資料表 成功")
            })
        } catch {
            print("創建偏好設定資料表 失敗")
        }
        initPreference()
    }
    private func initPreference() {
        do {
            try db?.run(_preference.insert(_newReply <- 0, _getMood <- false, _getLiked <- false, _getFollowed <- false, _newMail <- false, _showTheme <- 0, _autoPlayVedio <- 0, _touchIDOn <- false))
            print("新增偏好設定資料表 成功")
        } catch {
            print("新增偏好設定資料表 失敗")
        }
    }
    func updatePreference(preference: Preference) {
        do {
            try db.run(_preference.update([_newReply <- preference.newReply, _getMood <- preference.getMood, _getLiked <- preference.getLiked, _getFollowed <- preference.getFollowed, _newMail <- preference.newMail, _showTheme <- preference.showTheme, _autoPlayVedio <- preference.autoPlayVedio, _touchIDOn <- preference.touchIDOn]))
            print("更新偏好設定資料表 成功")
            ModelSingleton.shared.setPreference(preference)
        } catch {
            print("更新偏好設定資料表 失敗")
        }
    }
    func getPreference() {
        do {
            if let row = try db.pluck(_preference) {
                let preference = Preference(newReply: row[_newReply], getMood: row[_getMood], getLiked: row[_getLiked], getFollowed: row[_getFollowed], newMail: row[_newMail], showTheme: row[_showTheme], autoPlayVedio: row[_autoPlayVedio], touchIDOn: row[_touchIDOn])
                ModelSingleton.shared.setPreference(preference)
                print("取得偏好設定資料表 成功")
            }
        } catch {
            print("取得偏好設定資料表 失敗")
        }
    }
}
