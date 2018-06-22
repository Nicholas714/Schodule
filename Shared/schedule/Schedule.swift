//
//  Schedule.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

// TODO: turn back into a struct?
class Schedule: Codable {
    
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
    
    func setConstraints<T: TimeConstraint>(_ constraints: [T]) {
        _timeConstraints = constraints.map({ (constraint) -> TimeConstraintType in
            return TimeConstraintType(constraint)
        })
    }
    
    func append(course: Course) {
        replace(course: nil, with: course)
    }
    
    func replace(course oldCourse: Course?, with newCourse: Course) {
        if let old = oldCourse, let index = index(of: old) {
            classList.remove(at: index)
        }
        
        classList.append(newCourse)
        classList.sort()
        
        //SchooduleManager.shared.storage.saveSchedule()
    }
    
    func remove(course oldCourse: Course?) {
        if let old = oldCourse, let index = index(of: old) {
            classList.remove(at: index)
        }
        
        classList.sort()
        //SchooduleManager.shared.storage.saveSchedule()
    }
    
    private func index(of course: Course) -> Int? {
        if classList.isEmpty || !classList.contains(course) {
            return nil
        }
        return classList.index(of: course)
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
