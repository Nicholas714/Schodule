//
//  TimeConstraint.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/5/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

class TimeConstraint: Codable, Equatable {
    
    static func == (lhs: TimeConstraint, rhs: TimeConstraint) -> Bool {
        return lhs.getTitle() == rhs.getTitle()
    }
    
    func isInConstraint(_ date: Date) -> Bool {
        return false
    }
    func getTitle() -> String {
        return ""
    }
}

extension TimeConstraint {
    
    func isNow() -> Bool {
        return isInConstraint(Date())
    }
    
}

class Timeframe: TimeConstraint {
    
    var start: Time?
    var end: Time?
    
    override func isInConstraint(_ date: Date) -> Bool {
        return date <= end!.date && date >= start!.date
    }
    
    override func getTitle() -> String {
        return start!.date.timeString
    }
    
}

class Dateframe: TimeConstraint {
    
    var start: Date?
    var end: Date?
    
    override func isInConstraint(_ date: Date) -> Bool {
        return date <= start! && date >= end!
    }
    
    override func getTitle() -> String {
        return start!.dayString
    }
    
}

class AlternatingEven: TimeConstraint {
    
    override func isInConstraint(_ date: Date) -> Bool {
        return Calendar.current.component(.day, from: Date()) % 2 == 0
    }
    
    override func getTitle() -> String {
        return "Even Days"
    }
    
}

class AlternatingOdd: TimeConstraint {
    
    override func isInConstraint(_ date: Date) -> Bool {
        return Calendar.current.component(.day, from: Date()) % 2 != 0
    }
    
    override func getTitle() -> String {
        return "Odd Days"
    }
}

class SpecificDay: TimeConstraint {

    var days = [Day]()
    
    override func isInConstraint(_ date: Date) -> Bool {
        if let today = Day(rawValue: Calendar.current.component(.day, from: date)) {
            return days.contains(today)
        }
        return false
    }
    
    override func getTitle() -> String {
        if days.count == 1 {
            return days.first!.name
        }
        
        return days.map { (day) -> String in
            return day.shortName
        }.joined(separator: ", ")
    }
    
    
}

class Everyday: TimeConstraint {
    
    override func isInConstraint(_ date: Date) -> Bool {
        return true
    }
    
    override func getTitle() -> String {
        return "Everyday"
    }
    
}

class Weekend: TimeConstraint {
    
    override func isInConstraint(_ date: Date) -> Bool {
        return Calendar.current.isDateInWeekend(date)
    }
    
    override func getTitle() -> String {
         return "Weekends"
    }
}

class Weekday: TimeConstraint {
    
    override func isInConstraint(_ date: Date) -> Bool {
        return !Calendar.current.isDateInWeekend(date)
    }
    
    override func getTitle() -> String {
        return "Weekdays"
    }
    
}
