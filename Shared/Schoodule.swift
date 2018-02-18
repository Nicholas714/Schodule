//
//  Schoodule.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/29/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation
import UIKit

class Schoodule {

    var hasPendingSend = false
    var unsortedPeriods = [Period]()
    
    var transfer: [String: Data] {
        return ["periods": storage.encoded]
    }
    
    var periods: [Period] {
        get {
            return unsortedPeriods.sorted()
        }
    }
    
    var lastPeriod: Period? {
        return periods.last
    }
    
    var pendingTableScrollIndex: Int?
    
    lazy var storage: Storage = {
        return Storage(schoodule: self)
    }()
    
    func replace(old oldPeriod: Int?, with newPeriod: Period) {
        if let old = oldPeriod {
            unsortedPeriods.remove(at: old)
        }
        
        unsortedPeriods.append(newPeriod)
        
        hasPendingSend = true
    }
    
    func removePeriod(index: Int?) {
        if let i = index {
            unsortedPeriods.remove(at: i)
            hasPendingSend = true
        }
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
    
    func clear() {
        unsortedPeriods.removeAll()
        pendingTableScrollIndex = nil
    }
    
}
