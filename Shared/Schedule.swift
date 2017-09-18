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
        for perName in periods {
            
            // extend for 5 min for Pledge / Announcements
            if perName == "Electronics 1" {
                currentTime += 5
            }
            
            currentTime += classPeriodTime
            let period = Period(name: perName, endTime: currentTime)
            self.periods.append(period)
            
            currentTime += hallTime
            let hallway = Period(name: "Hallway", endTime: currentTime, isHallway: true)
            self.periods.append(hallway)
        }
        
    }
    
    func periodFromTime(date: Date = Date()) -> Period? {
        let time = date.timeIntervalSince(start) / 60.0
        
        if (time < 0) {
            return nil
        }
        
        print("====")
        print(start)
        print(Date())
        
        for period in periods {
            if time <= period.endTime {
                period.timeLeft = time
                print(period.name)
                return period
            }
        }
        
        return nil
    }
    
}

class Period {
    
    let isHallway: Bool
    let name: String
    let endTime: TimeInterval
    var timeLeft: TimeInterval = 0

    init(name: String, endTime: TimeInterval, isHallway: Bool  = false) {
        self.name = name
        self.endTime = endTime
        self.isHallway = isHallway
    }
    
}
