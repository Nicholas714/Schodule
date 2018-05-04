//
//  Schoodule.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/29/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

class Schoodule {

    var hasPendingSend = false
    var unsortedPeriods = Set<Period>()
    
    var transfer: [String: Data] {
        return ["periods": storage.encoded]
    }
    
    var periods = [Period]()
    
    var lastPeriod: Period? {
        return periods.last
    }
    
    var pendingTableScrollIndex: Int?
    
    lazy var storage: Storage = {
        return Storage(schoodule: self)
    }()
    
    func replace(old oldPeriod: Period?, with newPeriod: Period) {
        if let old = oldPeriod {
            unsortedPeriods.remove(old)
        }
        
        unsortedPeriods.insert(newPeriod)
        
        hasPendingSend = true
        
        periods = unsortedPeriods.sorted()
        SchooduleManager.shared.saveSchedule()
    }
    
    func remove(old oldPeriod: Period?) {
        if let old = oldPeriod {
            unsortedPeriods.remove(old)
            hasPendingSend = true
        }
        
        periods = unsortedPeriods.sorted()
        SchooduleManager.shared.saveSchedule()
    }
    
    func clear() {
        unsortedPeriods.removeAll()
        pendingTableScrollIndex = nil
        periods = [Period]()
        SchooduleManager.shared.saveSchedule()
    }
    
    func index(of period: Period) -> Int? {
        if periods.isEmpty || !periods.contains(period) {
            return nil
        }
        return periods.index(of: period)
    }
    
    func classFrom(date: Date) -> Period? {
        return periods.first { (period) -> Bool in
            return date <= period.end.date && date >= period.start.date
        }
    }
    
    func nextClassFrom(date: Date) -> Period? {
        return periods.first { (period) -> Bool in
            return date < period.start.date
        }
    }
    
}
