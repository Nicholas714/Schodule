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

    var unsortedPeriods = [Period]()
    
    var periods: [Period] {
        get {
            return unsortedPeriods.sorted()
        }
    }
    
    var pendingTableScrollIndex: Int?
    
    lazy var storage: Storage = {
        return Storage(schoodule: self)
    }()
    
    // TODO: remove
    init() {
        var prev = Calendar.current.date(bySetting: .second, value: 0, of: Date().addingTimeInterval(-9600))!
        for name in ["Economics", "Electronics", "Statistics", "Lunch", "Calculus", "Comp Sci", "Literature", "Gym", "Physics"] {
            let start = Calendar.current.date(bySetting: .second, value: 0, of: prev)!
            let end = Calendar.current.date(bySetting: .second, value: 0, of: prev.addingTimeInterval(40 * 60))!

            let period = Period(className: name, themeIndex: 0, start: start, end: end)
            unsortedPeriods.append(period)

            prev = end.addingTimeInterval(5 * 60)
        }
    }
    
    func replace(old oldPeriod: Int?, with newPeriod: Period) {
        if let old = oldPeriod {
            unsortedPeriods.remove(at: old)
        }
        
        unsortedPeriods.append(newPeriod)
        
        storage.saveSchedule()
    }
    
    func removePeriod(_ period: Period) {
        if let oldIndex = unsortedPeriods.index(of: period) {
            unsortedPeriods.remove(at: oldIndex)
        }
        storage.saveSchedule()
    }
    
    func index(of period: Period) -> Int? {
        return periods.index(of: period)
    }
    
    func classFrom(date: Date) -> Period? {
        return periods.first { (period) -> Bool in
            return date <= period.end && date >= period.start
        }
    }
    
    func nextClassFrom(date: Date) -> Period? {
        return periods.first { (period) -> Bool in
            return date < period.start
        }
    }
    
}
