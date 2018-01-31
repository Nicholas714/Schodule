//
//  Schoodule.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/29/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation
import UIKit
import ClockKit

class Schoodule {
    
    var periods = [Period]()
    
    init() {
        loadScheudle()
    }
    
    func removePeriod(at index: Int) {
        
    }
    
    func renamePeriod(at index: Int, with newName: Period) {
        
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
    
    func saveSchedule() {
        
    }
    
    func loadScheudle() {
        var prev = Calendar.current.date(bySetting: .second, value: 0, of: Date().addingTimeInterval(-9600))!
        for (index, name) in ["Economics", "Electronics", "Statistics", "Lunch", "Calculus", "Comp Sci", "Literature", "Gym", "Physics"].enumerated() {
            let start = Calendar.current.date(bySetting: .second, value: 0, of: prev)!
            let end = Calendar.current.date(bySetting: .second, value: 0, of: prev.addingTimeInterval(40.min))!
            
            let period = Period(index: index, className: name, color: UIColor.orange, start: start, end: end)
            periods.append(period)
            
            prev = end.addingTimeInterval(5.min)
        }
    }
    
}

extension Int {
    
    var min: TimeInterval {
        get {
            return TimeInterval(self * 60)
        }
    }
    
}
