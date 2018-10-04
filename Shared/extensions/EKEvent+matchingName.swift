//
//  EKEvent+matchingName.swift
//  Schoodule
//
//  Created by Nicholas Grana on 10/3/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import EventKit

extension EKEventStore {
    
    static var store = EKEventStore()
    
    func allCoursesInCalendar() -> [Course] {
        let year: TimeInterval = 604800
        let predicate = predicateForEvents(withStart: Date().addingTimeInterval(-year), end: Date().addingTimeInterval(year), calendars: nil)
        let eventsFound = events(matching: predicate)
        
        var courses = [Course]()
        
        for event in eventsFound {
            let newCourse = Course(event: event, color: Color.unselected)
            if !courses.contains(newCourse) {
                newCourse.events = eventsMatching(course: newCourse, in: eventsFound)
                courses.append(newCourse)
            }
        }
        
        return courses
    }
    
    func eventsMatching(course: Course, in foundEvents: [EKEvent]?) -> [Event] {
        var events = [Event]()
        var loopEvents: [EKEvent]
        
        if foundEvents == nil {
            let year: TimeInterval = 604800
            let predicate = predicateForEvents(withStart: Date().addingTimeInterval(-year), end: Date().addingTimeInterval(year), calendars: nil)
            loopEvents = self.events(matching: predicate)
        } else {
            loopEvents = foundEvents!
        }
        
        for event in loopEvents {
            let newEvent = Event(event: event, color: course.color)
            if event.title == course.name {
                events.append(newEvent)
            }
        }
        
        return events
    }
    
}

