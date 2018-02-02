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
        return Storage(schoodule: self)
    }()
    
    func replace(period index: Int, with newPeriod: Period) {
        periods[index] = newPeriod
        storage.saveSchedule()
    }
    
    func add(with newPeriod: Period) {
        periods.append(newPeriod)
        storage.saveSchedule()
    }
    
    func removePeriod(at index: Int) {
        periods.remove(at: index)
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
    
}
