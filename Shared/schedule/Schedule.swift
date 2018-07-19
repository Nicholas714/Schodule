//
//  Schedule.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

class Schedule: Codable {
    
    // MARK: Properties
    
    var classList = [Course]() {
        didSet {
            classList.sort()
        }
    }
    
    private var _timeConstraints = [TimeConstraintType]()
    
    var timeConstraints: [TimeConstraint] {
        var constraints = [TimeConstraint]()
        
        for constraint in _timeConstraints {
            switch constraint {
            case .timeframe(let t):
                constraints.append(t)
            case .term(let t):
                constraints.append(t)
            case .repeating(let t):
                constraints.append(t)
            case .alternatingEven(let t):
                constraints.append(t)
            case .alternatingOdd(let t):
                constraints.append(t)
            case .specificDays(let t):
                constraints.append(t)
            }
        }
        
        return constraints
    }
    
    var term: Term?
    
    var title: String {
        return timeConstraints.isEmpty ? "" : timeConstraints[0].title
    }
    
    // MARK: Schedule editing / getting
    
    func setConstraints(_ constraints: [TimeConstraint]) {
        _timeConstraints = constraints.map({ (constraint) -> TimeConstraintType in
            return TimeConstraintType(constraint)
        })
    }
    
    func isScheduleIn(date: Date) -> Bool {
        for constraint in timeConstraints {
            if !constraint.isInConstraint(date) {
                return false
            }
        }
        return true
    }
    
}

extension Schedule: Equatable {
    
    static func == (lhs: Schedule, rhs: Schedule) -> Bool {
        return lhs.title == rhs.title && lhs.classList == rhs.classList
    }
    
}
