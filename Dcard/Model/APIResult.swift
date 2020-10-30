//
//  APIResult.swift
//  Dcard
//
//  Created by Mason on 2020/10/30.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation

public enum BusinesslogicError {
    case card(Int)
    case post(Int)
    
    public var errorMessage: String {
        switch self {
        case .card(_):
            return ""
        case .post(_):
            return ""
        }
    }
}

public struct FirebaseResult<T> {
    public var data: T
    public var errorMessage: BusinesslogicError?
}
