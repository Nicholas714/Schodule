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
        return array.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.0 < rhs.0
        })
    }
    
    var todaySchedules: [Schedule] {
        return getSchedulesIn(date: Date()).sorted()
    }
    
    var todayCourses: [Course] {
        return todaySchedules.flatMap({ (schedule) -> [Course] in
            return schedule.classList
        }).sorted()
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
