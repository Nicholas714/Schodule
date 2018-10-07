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
        var today = [Course]()
        
        EKEventStore.store.eventsForDate(date: Date()).forEach { (date, event) in
            if let index = courses.firstIndex(of: Course(event: event, color: Color.unselected)) {
                today.append(courses[index])
            }
        }
        
        return today
    }
    
    var todayEvents: [Event] {
        var today = [Event]()
        
        EKEventStore.store.eventsForDate(date: Date()).forEach { (date, event) in
            if let course = courses.firstIndex(of: Course(event: event, color: Color.unselected)) {
                today.append(Event(event: event, color: courses[course].color))
            }
        }
        
        return today.sorted()
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
