//
//  Extension_Int.swift
//  Dcard
//
//  Created by Mason on 2020/10/24.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation

extension Int {
    func findMultipleBaseTen() -> Int {
        var initValue = self
        var count = 0
        while initValue / 10 > 0 {
            count += 1
            initValue = initValue / 10
        }
        return count
    }
}
