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
    
    func saveSchedule() {
        
    }
    
    func loadScheudle() {
        let elct1 = Calendar.current.date(bySetting: .second, value: 0, of: Date())!
        let elct2 = Calendar.current.date(bySetting: .second, value: 0, of: Date().addingTimeInterval(40 * 60))!
        let stat1 = Calendar.current.date(bySetting: .second, value: 0, of: elct2.addingTimeInterval(10 * 60))!
        let stat2 = Calendar.current.date(bySetting: .second, value: 0, of: stat1.addingTimeInterval(90 * 60))!
        
        let period = Period(className: "electronics", start: elct1, end: elct2)
        periods.append(period)
        periods.append(Period(className: "stats", start: stat1, end: stat2))
        /*for (index, name) in ["Economics", "Electronics", "Statistics", "Lunch", "Calculus", "Comp Sci", "Literature", "Gym", "Physics"].enumerated() {
            periods.append(Periodz(index: index, className: name, duration: 40))
        }*/
    }
    
}
