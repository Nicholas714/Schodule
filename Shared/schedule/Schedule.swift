//
//  Schedule.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import EventKit

class Schedule: Codable, Equatable {
    
    static func ==(lhs: Schedule, rhs: Schedule) -> Bool {
        return lhs.courses.flatMap { $0.events } == rhs.courses.flatMap { $0.events }
    }
    
    var courses = [Course]()
    
    var todayCourses: [Course] {
        return courses.filter { !$0.todayEvents.isEmpty }
    }
    
    var todayEvents: [Event] {
        return courses.flatMap { $0.todayEvents }.sorted()
    }
    
    func eventFrom(date: Date) -> Event? {
        return todayEvents.first { (event) -> Bool in
            return date <= event.endDate && date >= event.startDate
        }
    }
    
    func nextEventFrom(date: Date) -> Event? {
        return todayEvents.first { (event) -> Bool in
            return date < event.startDate
        }
    }
    
}
