//
//  Schedule.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

struct Schedule: Codable {
    
    var classList = [Course]() {
        didSet {
            print("classList set")
            classList.sort()
        }
    }
    
    private var _scheduleType: ScheduleConstraintType
    
    var scheduleType: ScheduleType {
        get {
            switch _scheduleType {
            case .repeating(let repeating):
                return repeating
            case .alternatingEven(let alternatingEven):
                return alternatingEven
            case .alternatingOdd(let alternatingOdd):
                return alternatingOdd
            case .specificDays(let alternatingOdd):
                return alternatingOdd
            }
        }
        set {
            _scheduleType = ScheduleConstraintType(newValue)
        }
    }
    
    var term: Term
    
    var title: String {
        return "\(scheduleType.title) \t\t\t\t\t\t\t\t\t\t\t\(term.title)"
    }
    
    init(scheduleType: ScheduleType, term: Term) {
        self._scheduleType = ScheduleConstraintType(scheduleType)
        self.term = term
    }
    
    func isScheduleIn(date: Date) -> Bool {
        return term.isInConstraint(date) && scheduleType.isInConstraint(date)
    }
    
}

extension Schedule: Equatable, Comparable {
    
    static func < (lhs: Schedule, rhs: Schedule) -> Bool {
        return lhs.term.start < rhs.term.start
    }
    
    static func ==(lhs: Schedule, rhs: Schedule) -> Bool {
        return lhs.title == rhs.title && lhs.term == rhs.term
    }
    
}
