//
//  Schedule.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

enum ScheduleStatus: Int {
    case empty
    case schedules
    case both
}

class Schedule: Codable {
    
    var periods = [Period]()
    //var timeConstraints = [TimeConstraint]()
    
    var lastPeriod: Period? {
        return periods.last
    }
    
    var isToday: Bool {
        /*for constraint in timeConstraints {
            if !constraint.isToday() {
                return false
            }
        }*/
        return true
    }
    
    // MARK: Getting Data
    
    func classFrom(date: Date) -> Period? {
        return periods.first { (period) -> Bool in
            return date <= period.timeframe.end.date && date >= period.timeframe.start.date
        }
    }
    
    func nextClassFrom(date: Date) -> Period? {
        return periods.first { (period) -> Bool in
            return date < period.timeframe.start.date
        }
    }
    
    // MARK: Schedule Manipulation
    
    func append(new period: Period) {
        replace(old: nil, with: period)
    }
    
    func replace(old oldPeriod: Period?, with newPeriod: Period) {
        if let old = oldPeriod, let index = index(of: old) {
            periods.remove(at: index)
        }
        
        periods.append(newPeriod)
        periods.sort()
        
        SchooduleManager.shared.storage.saveSchedule()
    }
    
    func remove(old oldPeriod: Period?) {
        if let old = oldPeriod, let index = index(of: old) {
            periods.remove(at: index)
        }
        
        periods.sort()
        SchooduleManager.shared.storage.saveSchedule()
    }
    
    func index(of period: Period) -> Int? {
        if periods.isEmpty || !periods.contains(period) {
            return nil
        }
        return periods.index(of: period)
    }
    
}
