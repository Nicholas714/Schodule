//
//  Schedule.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

struct Schedule: Codable {
    
    // MARK: Properties
    
    var classList = [Course]() {
        didSet {
            classList.sort()
        }
    }
    
    // TODO: remove optionals off schedule types and term
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
        return scheduleType.title
    }
    
    init(scheduleType: ScheduleType, term: Term) {
        self._scheduleType = ScheduleConstraintType(scheduleType)
        self.term = term
    }
    
    func isScheduleIn(date: Date) -> Bool {
        return term.isInConstraint(date) && scheduleType.isInConstraint(date)
    }
    
}

extension Schedule: Equatable {
    
    static func ==(lhs: Schedule, rhs: Schedule) -> Bool {
        print("\(lhs.title) == \(rhs.title) && \(lhs.term) == \(rhs.term)")
        return lhs.title == rhs.title && lhs.term == rhs.term
    }
    
}
