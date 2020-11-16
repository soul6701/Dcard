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
    
    static private let containTimeString = "yyyy/MM/dd HH:mm"
    static private let notContainTimeString = "yyyy/MM/dd"
    static let monthList = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    static var calendar: Calendar {
        return Calendar(identifier: .gregorian)
    }
    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_Hant_TW")
        return dateFormatter
    }()
    ///取得當前時間
    static func getCurrentDateString(_ containTime: Bool) -> String {
        self.dateFormatter.dateFormat = containTime ? containTimeString : notContainTimeString
        let currentDateString = dateFormatter.string(from: Date())
        return currentDateString
    }
    ///取得與特定時間的時間差
    static func getTimeIntervalSince(_ dateString: String) -> String {
        self.dateFormatter.dateFormat = notContainTimeString
        let date = dateFormatter.date(from: dateString) ?? Date()
        let components = self.calendar.dateComponents([.year, .month], from: date, to: Date())
        return "已註冊 \((String)(components.year!))年 \((String)(components.month!))個月"
    }
    ///是否更新Firebase貼文資料庫
    static func shouldUpdatePostData(lastTime dateString: String) -> Bool {
        self.dateFormatter.dateFormat = containTimeString
        let date = dateFormatter.date(from: dateString) ?? Date()
        let components = self.calendar.dateComponents([.minute], from: date, to: Date())
        if (components.minute ?? 0) > 30 {
            return true
        }
        return false
    }
    ///取得當月第一天（年、月）
    var FirstDayInMonth: Date {
        let _firstDay: DateComponents = Date.calendar.dateComponents([.year, .month], from: self)
        return Date.calendar.date(from: _firstDay)!
    }
    ///當月天數
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
    ///上個月
    var lastDateByMonth: Date {
        return Date.calendar.date(byAdding: .month, value: -1, to: self)!
    }
    ///下個月
    var nextDateByMonth: Date {
        return Date.calendar.date(byAdding: .month, value: 1, to: self)!
    }
    ///指定時間
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
