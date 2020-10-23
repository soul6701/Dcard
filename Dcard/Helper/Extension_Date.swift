//
//  File.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/14.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    
    static let monthList = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    static var calendar: Calendar {
        return Calendar(identifier: .gregorian)
    }
    static func getCurrentDateString(_ containTime: Bool) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_Hant_TW")
        dateFormatter.dateFormat = containTime ? "yyyy/MM/dd HH:mm" : "yyyy/MM/dd"
        let currentDateString = dateFormatter.string(from: Date())
        return currentDateString
    }
    
    var FirstDayInMonth: Date {
        let _firstDay: DateComponents = Date.calendar.dateComponents([.year, .month], from: self)
        return Date.calendar.date(from: _firstDay)!
    }
    var totalDayInThisMonth: Int {
        return Date.calendar.range(of: .day, in: .month, for: self)?.count ?? 0
    }
    var month: Month {
        let month = Date.calendar.component(.month, from: self)
        return Month(month, Date.monthList[month - 1])
    }
    var year: Int {
        return Date.calendar.component(.year, from: self)
    }
    var day: Int {
        return Date.calendar.component(.day, from: self)
    }
    var weekDay: Int {
        return Date.calendar.component(.weekday, from: self)
    }
    var lastDateByMonth: Date {
        return Date.calendar.date(byAdding: .month, value: -1, to: self)!
    }
    var nextDateByMonth: Date {
        return Date.calendar.date(byAdding: .month, value: 1, to: self)!
    }
    func setDay(_ day: Int) -> Date {
        let distance = day - self.day
        return Date.calendar.date(byAdding: .day, value: distance, to: self)!
    }
}

class Month {
    var description: String
    var number: Int
    
    init(_ number: Int, _ description: String) {
        self.number = number
        self.description = description
    }
}
