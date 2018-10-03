//
//  EKEvent+matchingName.swift
//  Schoodule
//
//  Created by Nicholas Grana on 10/3/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import EventKit

extension EKEventStore {
    
    func allCoursesInCalendar() -> [Course] {
        let year: TimeInterval = 3.15576e07
        let predicate = predicateForEvents(withStart: Date().addingTimeInterval(-year), end: Date().addingTimeInterval(year), calendars: nil)
        let eventsFound = events(matching: predicate)
        
        var courses = [Course]()
        
        for event in eventsFound {
            // TODO: don't load events
            let newCourse = Course(event: event, color: Color.randomBackground)
            if !courses.contains(newCourse) {
                newCourse.events = eventsMatching(course: course, in: eventsFound)
                courses.append(newCourse)
            }
        }
        
        return courses
    }
    
    func eventsMatching(course: Course, in foundEvents: [EKEvent]) -> [Event] {
        var events = [Event]()
        
        for event in foundEvents {
            if event.title == course.name {
                events.append(Event(course: course, event: event))
            }
        }
        
        return events
    }
    
}

