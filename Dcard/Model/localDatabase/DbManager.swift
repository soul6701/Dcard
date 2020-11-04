//
//  DbManager.swift
//  Dcard
//
//  Created by admin on 2020/10/12.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import SQLite

var db: Connection!

public class DbManager {
    public static var shared = DbManager()
    //與資料庫建立連線
    private init() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/db.sqlite3"
        do {
            db = try Connection(path)
            print("與資料庫建立連線 成功")
            print("資料庫路徑: \(path)")
//            deleteAllTables()
            createAllTables()
        } catch {
            print("與資料庫建立連線 失敗：\(error)")
        }
    }
    //創建所有資料表
    private func createAllTables() {
        createPreferenceTable()
        createTimeTable()
    }
    //移除所有資料表
    private func deleteAllTables() {
        do {
            try db.run(_preference.drop(ifExists: true))
            print("移除所有資料表 成功")
        } catch {
            print("移除所有資料表 失敗")
        }
    }
}
