//
//  Extension_Double.swift
//  Dcard
//
//  Created by mason on 2020/11/26.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation

// 科學記號
postfix operator ^
postfix func ^ (num: Int) -> String {
    let _pow : Int = num.getPowByTen()
    switch _pow {
    case 3...5:
        return "\((Double(num) / pow(10, 3)).rounding(to: 1))k"
    case 6...8:
        return "\((Double(num) / pow(10, 6)).rounding(to: 1))M"
    default:
        return "\(num)"
    }
}
extension Double {
    ///無條件去小數點Ｘ位以下
    func floor(to decimal: Int) -> Double {
        let numberOfDigits = pow(10.0, Double(decimal))
        return (self * numberOfDigits).rounded(.towardZero) / numberOfDigits
    }
    ///四捨五入小數點Ｘ位以下
    func rounding(to decimal: Int) -> Double {
        let numberOfDigits = pow(10.0, Double(decimal))
        return (self * numberOfDigits).rounded(.toNearestOrAwayFromZero) / numberOfDigits
    }
}
