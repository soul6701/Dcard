//
//  UserDefaultsKeys.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/25.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

//登入
let Login_account = "Login_歷史帳號"

public class UserDefaultsKeys {
    public static var shared = UserDefaultsKeys()
    public var loginReset = false //未清除
    
    static var account: [String:Date] {
        return UserDefaults.standard.dictionary(forKey: Login_account) as? [String:Date] ?? [:]
    }
    
    //存檔
    func setValue(_ value: Any?, forKey key: String) {
        //清除一天前登入資料
        if key == Login_account {
            if let _ = UserDefaults.standard.dictionary(forKey: Login_account) {
                let dir = value as! [String:Date]
                var _dir = UserDefaultsKeys.account
                removeKeysByString(prefix: "Login")
                for key in _dir.keys {
                    if let date = _dir[key] {
                        let interval = Date.today.timeIntervalSince(date)
                        let hours = floor((interval / 3600))
                        if hours >= 4 {
                            _dir[key] = nil
                        }
                    }
                }
                _dir[dir.keys.first!] = dir.values.first!
                UserDefaults.standard.setValue(_dir, forKey: Login_account)
            } else {
                UserDefaults.standard.setValue(value, forKey: Login_account)
            }
        } else {
            UserDefaults.standard.setValue(value, forKey: key)
        }
    }
    //移除特定暫存紀錄
    func removeKeysByString(prefix string: String) {
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key.hasPrefix(string) {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
    //移除所有紀錄
    func removeAllKeys() {
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
