//
//  TimeConstraint.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/5/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

protocol TimeConstraint: Codable {
    func isInConstraint(_ date: Date) -> Bool
    func getTitle() -> String
}

extension TimeConstraint {
    
    func isNow() -> Bool {
        return isInConstraint(Date())
    }
    
}

struct Timeframe: TimeConstraint, Equatable {
    
    var start: Time
    var end: Time
    
    func isInConstraint(_ date: Date) -> Bool {
        return date <= end.date && date >= start.date
    }
    
    func getTitle() -> String {
        return start.date.timeString
    }
    
}

struct Dateframe: TimeConstraint, Codable {
    
    var start: Date
    var end: Date
    
    func isInConstraint(_ date: Date) -> Bool {
        return date <= start && date >= end
    }
    
    func getTitle() -> String {
        return start.dayString
    }
    
}

struct AlternatingEven: TimeConstraint {
    
    func isInConstraint(_ date: Date) -> Bool {
        return Calendar.current.component(.day, from: Date()) % 2 == 0
    }
    
    func getTitle() -> String {
        return "Even Days"
    }
    
}

struct AlternatingOdd: TimeConstraint {
    
    func isInConstraint(_ date: Date) -> Bool {
        return Calendar.current.component(.day, from: Date()) % 2 != 0
    }
    
    func getTitle() -> String {
        return "Odd Days"
    }
}

struct SpecificDay: TimeConstraint, Equatable {

    var days: [Day]
    
    func isInConstraint(_ date: Date) -> Bool {
        if let today = Day(rawValue: Calendar.current.component(.day, from: date)) {
            return days.contains(today)
        }
        return false
    }
    
    func getTitle() -> String {
        if days.count == 1 {
            return days.first!.name
        }
        
        return days.map { (day) -> String in
            return day.shortName
        }.joined(separator: ", ")
    }
    
    
}

struct Everyday: TimeConstraint {
    
    func isInConstraint(_ date: Date) -> Bool {
        return true
    }
    
    func getTitle() -> String {
        return "Everyday"
    }
    
}

struct Weekend: TimeConstraint {
    
    func isInConstraint(_ date: Date) -> Bool {
        return Calendar.current.isDateInWeekend(date)
    }
    
    func getTitle() -> String {
         return "Weekends"
    }
}

struct Weekday: TimeConstraint {
    
    func isInConstraint(_ date: Date) -> Bool {
        return !Calendar.current.isDateInWeekend(date)
    }
    
    func getTitle() -> String {
        return "Weekdays"
    }
    
}
