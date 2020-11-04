//
//  DbManager+Time.swift
//  Dcard
//
//  Created by Mason on 2020/11/4.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import SQLite

//時間資訊
let _time = Table("Time")
let _id = Expression<Int>("id")
let _startTime = Expression<String>("start_time")

extension DbManager {

    func createTimeTable() {
        do {
            try db.run(_time.create(ifNotExists: true) { tb in
                tb.column(_id, primaryKey: .autoincrement)
                tb.column(_startTime)
                print("創建時間設定資料表 成功")
            })
        } catch {
            print("創建時間設定資料表 失敗")
        }
    }
    func insertTime(time: String) {
        do {
            try db?.run(_time.insert(_startTime <- time))
            print("新增時間設定資料表 成功")
        } catch {
            print("新增時間設定資料表 失敗")
        }
    }
    func getLastTime() -> String? {
        guard let db = db else { return nil }
        do {
            let count = try db.scalar(_time.count)
            if count != 0 {
                let rows = try db.prepare(_time.select(_startTime, _id).filter(_id == count ))
                return rows.first(where: {
                    $0[_id] == count
                })?[_startTime]
            } else {
                return nil
            }
        } catch {
            print("取得時間設定資料表 失敗")
            return nil
        }
    }
}
