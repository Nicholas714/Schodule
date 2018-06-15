//
//  SchooduleManager.swift
//  Schoodule
//
//  Created by Nicholas Grana on 2/11/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

struct ScheduleList: Codable {
    
    var schedules = [Schedule]()
    
    var todaySchedule: [Course] {
        return scheduleFor(date: Date())
    }
        
    func getSchedulesWith(timeConstraints: [TimeConstraint]) -> Schedule? {
        for schedule in schedules {
            if timeConstraints.count == schedule.timeConstraints.count {
                return schedule
            }
        }
        return nil 
    }
    
    func scheduleFor(date: Date) -> [Course] {
        return schedules.filter({ (schedule) -> Bool in
            return schedule.isScheduleIn(date: date)
        }).flatMap({ (schedule) -> [Course] in
            return schedule.classList
        })
    }
    
    func classFrom(date: Date) -> Course? {
        return todaySchedule.first { (course) -> Bool in
            return date <= course.timeframe.end.date && date >= course.timeframe.start.date
        }
    }
    
    func nextClassFrom(date: Date) -> Course? {
        return todaySchedule.first { (course) -> Bool in
            return date < course.timeframe.start.date
        }
    }
    
}
