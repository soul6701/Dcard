//
//  APIResult.swift
//  Dcard
//
//  Created by Mason on 2020/10/30.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation

public let loginError = ["找不到此用戶", "密碼錯誤", "信箱/手機錯誤"]
public let cardError = ["取得卡片失敗"]
public let postError: [String] = []

public enum BusinesslogicError {
    case login(Int)
    case card(Int)
    case post(Int)
    
    public var errorMessage: String {
        switch self {
        case .login(let i):
            return loginError[i]
        case .card(let i):
            return cardError[i]
        case .post(let i):
            return postError[i]
        }
    }
}
public struct FirebaseResult<T> {
    public var data: T
    public var errorMessage: BusinesslogicError?
    public var sender: [String: Any]?
}
