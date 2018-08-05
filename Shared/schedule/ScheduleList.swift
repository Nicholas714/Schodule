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
    
    var todayCourseEntries: [(Course, Schedule)] {
        var array = [(Course, Schedule)]()
        for schedule in todaySchedules {
            for course in schedule.classList {
                array.append((course, schedule))
            }
        }
        return array
    }
    
    var todaySchedules: [Schedule] {
        return getSchedulesIn(date: Date())
    }
    
    var todayCourses: [Course] {
        return todaySchedules.flatMap({ (schedule) -> [Course] in
            return schedule.classList
        })
    }
    
    var totalCourseCount: Int {
        return schedules.reduce(0, { $0 + $1.classList.count })
    }
    
    // MARK: Schedule editing and getting
    
    func getScheduleWith(scheduleType: ScheduleType, term: Term) -> Schedule? {
        let lookupSchedule = Schedule(scheduleType: scheduleType, term: term)
        for schedule in schedules {
            if schedule == lookupSchedule {
                return schedule
            }
        }
        return nil
    }
    
    func getSchedulesIn(date: Date) -> [Schedule] {
        return schedules.filter({ (schedule) -> Bool in
            return schedule.isScheduleIn(date: date)
        })
    }
    
    func classFrom(date: Date) -> Course? {
        return todayCourses.first { (course) -> Bool in
            return date <= course.timeframe.end.date && date >= course.timeframe.start.date
        }
    }
    
    func nextClassFrom(date: Date) -> Course? {
        return todayCourses.first { (course) -> Bool in
            return date < course.timeframe.start.date
        }
    }
    
}
