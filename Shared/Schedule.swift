//
//  Schdule.swift
//  Schodule
//
//  Created by Nicholas Grana on 9/13/17.
//  Copyright © 2017 Nicholas Grana. All rights reserved.
//

import Foundation

class Schedule {
    
    let start: Date
    let hallTime: TimeInterval
    let classPeriodTime: TimeInterval
    
    var periods = [Period]()
    
    init(start: Date, classPeriodTime: TimeInterval, hallTime: TimeInterval, periods: String...) {
        self.start = start
        self.classPeriodTime = classPeriodTime
        self.hallTime = hallTime
        
        var currentTime: TimeInterval = 0
        let periodEndTime = start
        
        for perName in periods {
            var periodTime = classPeriodTime
            
            // extend for 5 min for Pledge / Announcements
            if perName == "Electronics 1" {
                currentTime += 5
                periodTime += 5
            }
            
            currentTime += classPeriodTime
            let period = Period(name: perName, finishDate: periodEndTime.addingTimeInterval(currentTime * 60), time: periodTime)
            self.periods.append(period)
            
            currentTime += hallTime
            let hallway = Period(name: "Hallway", finishDate: periodEndTime.addingTimeInterval(currentTime * 60), time: hallTime)
            self.periods.append(hallway)
        }
        
        // remove hallway from last entry
        self.periods.removeLast()
    }
    
    func getClass(from date: Date = Date()) -> Period? {
        for period in periods where date <= period.finishDate && date >= start {
            return period
        }
        
        return nil
    }
    
}

class Period {
    
    let name: String
    let finishDate: Date
    let time: TimeInterval
    
    init(name: String, finishDate: Date, time: TimeInterval) {
        self.name = name
        self.finishDate = finishDate
        self.time = time
    }
    
}
