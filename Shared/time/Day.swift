//
//  Dayu.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/5/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

enum Day: Int, Codable, CaseIterable {
    
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    static var everyday = Day.allCases
    
    var name: String {
        switch self {
        case .sunday:
            return "Sunday"
        case .monday:
            return "Monday"
        case .tuesday:
            return "Tuesday"
        case .wednesday:
            return "Wednesday"
        case .thursday:
            return "Thuesday"
        case .friday:
            return "Friday"
        case .saturday:
            return "Saturday"
        }
    }
    
    var shortName: String {
        return String(name.prefix(3))
    }
    
    var isWeekend: Bool {
        if let date = Calendar.current.date(bySetting: .day, value: rawValue, of: Date()) {
            return Calendar.current.isDateInWeekend(date)
        }
        return false
    }
    
    var isWeekday: Bool {
        return !isWeekend
    }

}
