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
        print("start \(start)")
        self.start = start
        self.classPeriodTime = classPeriodTime
        self.hallTime = hallTime
        
        var currentTime: TimeInterval = 0
        let periodEndTime = start
        for perName in periods {
            
            // extend for 5 min for Pledge / Announcements
            if perName == "Electronics 1" {
                currentTime += 5
            }
            
            currentTime += classPeriodTime
            let period = Period(name: perName, finishDate: periodEndTime.addingTimeInterval(currentTime * 60))
            self.periods.append(period)
            
            currentTime += hallTime
            let hallway = Period(name: "Hallway", finishDate: periodEndTime.addingTimeInterval(currentTime * 60), isHallway: true)
            self.periods.append(hallway)
        }
        
    }
    
    func getNextClass(date: Date = Date()) -> Period? {
        print(date)
        for period in periods where date <= period.finishDate {
            print("hi")
            return period
        }
        
        return nil
    }
    
}

class Period {
    
    let isHallway: Bool
    let name: String
    let finishDate: Date
    
    init(name: String, finishDate: Date, isHallway: Bool  = false) {
        self.name = name
        self.finishDate = finishDate
        self.isHallway = isHallway
    }
    
}
