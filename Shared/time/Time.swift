//
//  Time.swift
//  Schoodule
//
//  Created by Nicholas Grana on 2/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

struct Time: Codable, Comparable {
    
    var hour: Int // 0-23
    var minute: Int // 0-59
    
    var isAM: Bool {
        get {
            return hour <= 11
        }
        set (toAm) {
            if toAm {
                if hour - 12 < 0 {
                    return
                }
                hour -= 12
            } else {
                if hour + 12 > 23 {
                    return
                }
                hour += 12
            }
        }
    }
    
    init(from date: Date) {
        self.hour = Calendar.current.component(.hour, from: date)
        self.minute = Calendar.current.component(.minute, from: date)
    }
    
    init(_ hour: Int, _ minute: Int) {
        self.hour = hour
        self.minute = minute
    }
    
    var date: Date {
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
    }
    
    static func <(lhs: Time, rhs: Time) -> Bool {
        return lhs.date < rhs.date
    }
    
    static func ==(lhs: Time, rhs: Time) -> Bool {
        return lhs.hour == rhs.hour && lhs.minute == rhs.minute
    }
}
