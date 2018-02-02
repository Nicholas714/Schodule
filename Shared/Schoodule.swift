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
    
    lazy var storage: Storage = {
        return Storage(schoodule: self)
    }()
    
    func replace(old oldPeriod: Period, with newPeriod: Period) {
        if let oldIndex = unsortedPeriods.index(of: oldPeriod) {
            unsortedPeriods.remove(at: oldIndex)
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
    
    func addPeriod(period: Period) {
        unsortedPeriods.append(period)
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
