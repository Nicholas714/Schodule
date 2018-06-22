//
//  TimeConstraint.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/5/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

enum TimeConstraintType: Codable {
    
    private enum Keys: CodingKey {
        case value
        case payload
    }
    
    private enum Values: Int, Codable {
        case timeframe
        case term
        case repeating
        case alternatingEven
        case alternatingOdd
        case specificDays
    }
    
    case timeframe(Timeframe)
    case term(Term)
    case repeating(Repeating)
    case alternatingEven(AlternatingEven)
    case alternatingOdd(AlternatingOdd)
    case specificDays(SpecificDay)
    
    init<T: TimeConstraint>(_ constraint: T) {
        if let item = constraint as? Timeframe {
            self = .timeframe(item)
        } else if let item = constraint as? Term {
            self = .term(item)
        } else if let item = constraint as? Repeating {
            self = .repeating(item)
        } else if let item = constraint as? AlternatingEven {
            self = .alternatingEven(item)
        } else if let item = constraint as? AlternatingOdd {
            self = .alternatingOdd(item)
        } else if let item = constraint as? SpecificDay {
            self = .specificDays(item)
        }else {
            fatalError()
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let value = try container.decode(Values.self, forKey: .value)
        switch value {
        case .timeframe:
            let payload = try container.decode(Timeframe.self, forKey: .payload)
            self = .timeframe(payload)
        case .term:
            let payload = try container.decode(Term.self, forKey: .payload)
            self = .term(payload)
        case .repeating:
            let payload = try container.decode(Repeating.self, forKey: .payload)
            self = .repeating(payload)
        case .alternatingEven:
            let payload = try container.decode(Timeframe.self, forKey: .payload)
            self = .timeframe(payload)
        case .alternatingOdd:
            let payload = try container.decode(Term.self, forKey: .payload)
            self = .term(payload)
        case .specificDays:
            let payload = try container.decode(SpecificDay.self, forKey: .payload)
            self = .specificDays(payload)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        switch self {
        case .timeframe(let payload):
            try container.encode(Values.timeframe, forKey: .value)
            try container.encode(payload, forKey: .payload)
        case .term(let payload):
            try container.encode(Values.term, forKey: .value)
            try container.encode(payload, forKey: .payload)
        case .repeating(let payload):
            try container.encode(Values.repeating, forKey: .value)
            try container.encode(payload, forKey: .payload)
        case .alternatingEven(let payload):
            try container.encode(Values.alternatingEven, forKey: .value)
            try container.encode(payload, forKey: .payload)
        case .alternatingOdd(let payload):
            try container.encode(Values.alternatingOdd, forKey: .value)
            try container.encode(payload, forKey: .payload)
        case .specificDays(let payload):
            try container.encode(Values.specificDays, forKey: .value)
            try container.encode(payload, forKey: .payload)
        }
    }
}

protocol TimeConstraint: Codable {
    var title: String { get }
    func isInConstraint(_ date: Date) -> Bool
}

protocol DynamicStartConstraint: TimeConstraint {
    var startDate: Date { get set }
    var daysUntilRepeat: Int { get set }
}

extension DynamicStartConstraint {
    
    func daysInBetween(_ date: Date) -> Int {
        return Int(abs(Double(date.timeIntervalSince1970 - startDate.timeIntervalSince1970) * (1 / 86400)))
    }
    
    func isInConstraint(_ date: Date) -> Bool {
        return daysInBetween(date) % daysUntilRepeat == 0
    }
}

extension TimeConstraint {
    
    func isNow() -> Bool {
        return isInConstraint(Date())
    }
    
}

struct Timeframe: TimeConstraint, Equatable, Codable {
    
    var start: Time
    var end: Time
    
    var title: String {
        return "1:30am - 2:00am"
    }
    
    func isInConstraint(_ date: Date) -> Bool {
        return date <= end.date && date >= start.date
    }
    
}

struct Term: TimeConstraint {
    
    var start: Date
    var end: Date?
    
    var title: String {
        return "May 23, 2018 - May 30, 2018"
    }
    
    func isInConstraint(_ date: Date) -> Bool {
        return date >= start && (end == nil ? true : date <= end!)
    }
    
}

struct AlternatingEven: DynamicStartConstraint {
    
    var daysUntilRepeat = 1
    var startDate: Date

    var title = "Even Days"
    
    init(startDate: Date) {
        self.startDate = startDate
    }
    
}

struct AlternatingOdd: DynamicStartConstraint {

    var daysUntilRepeat = 1
    var startDate: Date
    
    var title = "Odd Days"

    init(startDate: Date) {
        // add a day because odd starts on the next day
        self.startDate = startDate.addingTimeInterval(86400)
    }
    
}

struct SpecificDay: TimeConstraint {

    var days = [Day]()

    var title: String {
        if days.count == 7 {
            return "Everyday"
        }
    
        if days.count == 1 {
            return days.first!.name
        }
    
        var isWeekdayArray = true
        var isWeekendArray = true
        
        for day in days {
            if !day.isWeekend {
                isWeekendArray = false
            }
            if !day.isWeekday {
                isWeekdayArray = false
            }
        }
        
        if isWeekdayArray {
            return "Weekdays"
        }
        
        if isWeekendArray {
            return "Weekends"
        }
        
        return days.map { (day) -> String in
            return day.shortName
            }.joined(separator: ", ")
    }
    
    func isInConstraint(_ date: Date) -> Bool {
        if let today = Day(rawValue: Calendar.current.component(.weekday, from: date)) {
            return days.contains(today)
        }
        return false
    }
    
}

struct Repeating: DynamicStartConstraint {

    var daysUntilRepeat: Int
    var startDate: Date
    
    var title: String {
        return "Every \(daysUntilRepeat) \(daysUntilRepeat == 1 ? "day" : "days")"
    }

}
