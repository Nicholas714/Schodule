//
//  EventStore.swift
//  Schoodule
//
//  Created by Nicholas Grana on 10/5/18.
//  Copyright © 2018 Schoodule. All rights reserved.
//

import EventKit

extension EKEventStore {
    
    static var store = EKEventStore()
    
    func eventsForDate(date: Date) -> [Date: EKEvent] {
        let morning = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
        let night = morning.addingTimeInterval(86399)
        
        let predicate = predicateForEvents(withStart: morning, end: night, calendars: nil)
        let events = self.events(matching: predicate)
        
        var startTimeToEvents = [Date: EKEvent]()
        for event in events {
            startTimeToEvents[event.startDate] = event
        }
        
        return startTimeToEvents
    }
    
}


class EventStore {
    
    static var shared = EventStore()
    
    static func reloadYear() {
        EKEventStore.store.requestAccess(to: .event) { (accepted, error) in
            if !accepted || error != nil {
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                shared.eventsInYear = shared.eventsInYearSpan()
                shared.coursesInYear = shared.allCoursesInCalendar()
            }
        }
    }
    
    private var namesToEvents = [String: [EKEvent]]()
    
    var eventsInYear = [EKEvent]()
    var coursesInYear = [Course]()
    
    private init() { }
    
    func eventsMatching(course: Course) -> [Event] {
        let ekEvents = namesToEvents[course.name] ?? [EKEvent]()
        var events = [Event]()
        
        for ekEvent in ekEvents {
            let event = Event(event: ekEvent, color: course.color)
            events.append(event)
        }
        
        return Array(Set(events))
    }
    
    private func allCoursesInCalendar() -> [Course] {
        var courses = [Course]()
        
        for event in eventsInYear {
            let newCourse = Course(event: event, color: Color.unselected)
            if !courses.contains(newCourse) {
                newCourse.events = eventsMatching(course: newCourse)
                courses.append(newCourse)
            }
        }
        
        print("into \(courses.count)")
        
        return courses
    }
    
    private func eventsInYearSpan() -> [EKEvent] {
        let year: TimeInterval = 3.15576E+07
        let todayStart = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        
        let predicate = EKEventStore.store.predicateForEvents(withStart: todayStart, end: todayStart.addingTimeInterval(year), calendars: nil)
        let events = EKEventStore.store.events(matching: predicate)
        print("loaded \(events.count)")
        
        for event in events {
            var eventList = namesToEvents[event.title] ?? [EKEvent]()
            eventList.append(event)
            namesToEvents[event.title] = eventList
        }
        
        print("went through all")
        return events
    }
    
}
