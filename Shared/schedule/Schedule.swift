//
//  Schedule.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

struct Schedule: Codable {
    
    var classList = [Class]()
    private var _timeConstraints = [TimeConstraintType]()
    
    var timeConstraints: [TimeConstraint] {
        var constraints = [TimeConstraint]()
        
        for constraint in _timeConstraints {
            switch constraint {
            case .timeframe(let t):
                constraints.append(t)
            case .dateframe(let t):
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
    
    mutating func addConstrait<T: TimeConstraint>(_ constraint: T) {
        _timeConstraints.append(TimeConstraintType(constraint))
    }
    
    var lastPeriod: Class? {
        return classList.last
    }
    
    var dateframe: Dateframe? {
        return nil
    }
    
    var title: String? {
        // TODO: implement
        return ""
    }
    
    var isToday: Bool {
        return isScheduleInDate(Date())
    }
    
    // MARK: Getting Data
    
    mutating func classFrom(date: Date) -> Class? {
        return classList.first { (period) -> Bool in
            return date <= period.timeframe.end.date && date >= period.timeframe.start.date
        }
    }
    
    mutating func nextClassFrom(date: Date) -> Class? {
        return classList.first { (period) -> Bool in
            return date < period.timeframe.start.date
        }
    }
    
    // MARK: Schedule Manipulation
    
    mutating func append(new period: Class) {
        replace(old: nil, with: period)
    }
    
    mutating func replace(old oldPeriod: Class?, with newPeriod: Class) {
        if let old = oldPeriod, let index = index(of: old) {
            classList.remove(at: index)
        }
        
        classList.append(newPeriod)
        classList.sort()
        
        //SchooduleManager.shared.storage.saveSchedule()
    }
    
    mutating func remove(old oldPeriod: Class?) {
        if let old = oldPeriod, let index = index(of: old) {
            classList.remove(at: index)
        }
        
        classList.sort()
        //SchooduleManager.shared.storage.saveSchedule()
    }
    
    func index(of period: Class) -> Int? {
        if classList.isEmpty || !classList.contains(period) {
            return nil
        }
        return classList.index(of: period)
    }
    
    func isScheduleInDate(_ date: Date) -> Bool {
        for constraint in timeConstraints {
            if !constraint.isInConstraint(date) {
                return false
            }
        }
        return true
    }
    
}
