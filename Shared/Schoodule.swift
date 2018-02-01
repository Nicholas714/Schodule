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

    var periods = [Period]()
    
    lazy var storage: Storage = {
        let store = Storage(schoodule: self)
        store.loadScheudle()
        return store
    }()
    
    func removePeriod(at index: Int) {
        storage.saveSchedule()
    }
    
    func renamePeriod(at index: Int, with newName: Period) {
        storage.saveSchedule()
    }
    
    func addPeriod(period: Period) {
        // TODO: find index automatically
        periods.append(period)
        storage.saveSchedule()
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
    
    func indexOf(period: Period) -> Int? {
        return periods.index(of: period)
    }
    
}

extension Int {
    
    var min: TimeInterval {
        get {
            return TimeInterval(self * 60)
        }
    }
    
}
