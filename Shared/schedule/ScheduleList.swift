//
//  SchooduleManager.swift
//  Schoodule
//
//  Created by Nicholas Grana on 2/11/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

struct ScheduleList: Codable {
    
    // MARK: Properties
    
    var schedules = [Schedule]()
    
    var todaySchedule: [Course] {
        return getCoursesIn(date: Date())
    }
    
    var totalCourseCount: Int {
        return schedules.reduce(0, { $0 + $1.classList.count })
    }
    
    // MARK: Schedule editing and getting
    
    func getScheduleWith(timeConstraints: [TimeConstraint]) -> Schedule? {
        for schedule in schedules {
            let sendTimeConstraintsSet = Set(timeConstraints.map { $0.title })
            let loopTimeConstraintsSet = Set(schedule.timeConstraints.map { $0.title })
            
            if sendTimeConstraintsSet == loopTimeConstraintsSet {
                return schedule
            }
        }
        return nil
    }
    
    func getCoursesIn(date: Date) -> [Course] {
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
