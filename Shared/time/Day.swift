//
//  Dayu.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/5/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

enum Day: Int, Codable {
    
    case sunday 
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    static var everyday: [Day] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    static var weekdays: [Day] {
        return everyday.filter { $0.isWeekday }
    }
    
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
    
    var isWeekday: Bool {
        if let date = Calendar.current.date(bySetting: .weekday, value: rawValue, of: Date()) {
            return !Calendar.current.isDateInWeekend(date)
        }
        return false
    }

}
