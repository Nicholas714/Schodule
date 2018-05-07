//
//  TimeConstraint.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/5/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

protocol TimeConstraint {
    var title: String { get }
    func isInConstraint(_ date: Date) -> Bool
}

extension TimeConstraint {
    
    func isNow() -> Bool {
        return isInConstraint(Date())
    }
    
}

struct Timeframe: TimeConstraint, Equatable {
    
    var start: Time
    var end: Time
    
    var title: String {
        return start.date.timeString
    }
    
    func isInConstraint(_ date: Date) -> Bool {
        return date <= end.date && date >= start.date
    }
    
}

struct Dateframe: TimeConstraint {
    
    var start: Date
    var end: Date
    
    var title: String {
        return start.dayString
    }
    
    func isInConstraint(_ date: Date) -> Bool {
        return date <= start && date >= end
    }

}

struct AlternatingEven: TimeConstraint {
    
    var title = "Even Days"
    
    func isInConstraint(_ date: Date) -> Bool {
        return Calendar.current.component(.day, from: Date()) % 2 == 0
    }
    
}

struct AlternatingOdd: TimeConstraint {
    
    var title = "Odd Days"
    
    func isInConstraint(_ date: Date) -> Bool {
        return Calendar.current.component(.day, from: Date()) % 2 != 0
    }

}

struct SpecificDay: TimeConstraint {

    var title: String {
        if days.count == 1 {
            return days.first!.name
        }
        
        return days.map { (day) -> String in
            return day.shortName
            }.joined(separator: ", ")
    }
    
    var days = [Day]()
    
    func isInConstraint(_ date: Date) -> Bool {
        if let today = Day(rawValue: Calendar.current.component(.day, from: date)) {
            return days.contains(today)
        }
        return false
    }
    
}

struct Everyday: TimeConstraint {
    
    var title = "Everyday"
    
    func isInConstraint(_ date: Date) -> Bool {
        return true
    }
    
}

struct Weekend: TimeConstraint {
 
    var title = "Weekends"
    
    func isInConstraint(_ date: Date) -> Bool {
        return Calendar.current.isDateInWeekend(date)
    }
    
}

struct Weekday: TimeConstraint {
    
    var title = "Weekdays"
    
    func isInConstraint(_ date: Date) -> Bool {
        return !Calendar.current.isDateInWeekend(date)
    }
    
}
