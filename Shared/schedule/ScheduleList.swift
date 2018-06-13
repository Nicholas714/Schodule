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
    
    var todaySchedule: [Class] {
        return schedules.filter({ (schedule) -> Bool in
            return schedule.isScheduleInDate(Date())
        }).flatMap({ (schedule) -> [Class] in
            return schedule.classList
        })
    }
        
    func getSchedulesWith(timeConstraints: [TimeConstraint]) -> [Schedule] {
        var containingSchedules = [Schedule]()
        
        for schedule in schedules {
            if timeConstraints.count == schedule.timeConstraints.count {
                containingSchedules.append(schedule)
            }
        }
        
        return containingSchedules
    }
    
    func scheduleForDate(_ date: Date) -> [Class] {
        return schedules.filter({ (schedule) -> Bool in
            return schedule.isScheduleInDate(date)
        }).flatMap({ (schedule) -> [Class] in
            return schedule.classList
        })
    }
    
}
