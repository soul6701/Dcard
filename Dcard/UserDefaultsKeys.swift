//
//  UserDefaultsKeys.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/25.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

//登入
let Login_lastname = "Login_姓氏"
let Login_firstname = "Login_名字"

class UserDefaultsKeys {
    
    static var lastname: String {
        return UserDefaults.standard.string(forKey: Login_lastname) ?? ""
    }
    static var firstname: String {
        return UserDefaults.standard.string(forKey: Login_firstname) ?? ""
    }
    //存檔
    static func setValue(_ value: Any?, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    //移除特定暫存紀錄
    static func removeKeysByString(prefix string: String) {
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key.hasPrefix(string) {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        UserDefaults.standard.synchronize()
    }
    //移除所有紀錄
    static func removeAllKeys() {
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
    }
}
