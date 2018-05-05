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
    
}

struct Dateframe: TimeConstraint, Equatable {
    
    var start: Date
    var end: Date
    
    func isInConstraint(_ date: Date) -> Bool {
        return date <= start && date >= end
    }
    
}

struct AlternatingEven: TimeConstraint {
    
    func isInConstraint(_ date: Date) -> Bool {
        return Calendar.current.component(.day, from: Date()) % 2 == 0
    }
    
}

struct AlternatingOdd: TimeConstraint {
    
    func isInConstraint(_ date: Date) -> Bool {
        return Calendar.current.component(.day, from: Date()) % 2 != 0
    }
    
}

struct SpecificDay: TimeConstraint {
        
    var days: [Day]
    
    func isInConstraint(_ date: Date) -> Bool {
        if let today = Day(rawValue: Calendar.current.component(.day, from: date)) {
            return days.contains(today)
        }
        return false
    }
    
}

struct Everyday: TimeConstraint {
    
    func isInConstraint(_ date: Date) -> Bool {
        return true
    }
    
}
