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
    
    func eventsForDate(date: Date) -> [Date: [EKEvent]] {
        let morning = date.morning
        let night = date.night
        
        let predicate = predicateForEvents(withStart: morning, end: night, calendars: nil)
        let events = self.events(matching: predicate)

        var startTimeToEvents = [Date: [EKEvent]]()

        for event in events {
            var eventArray = startTimeToEvents[event.startDate] ?? [EKEvent]()
            eventArray.append(event)
            startTimeToEvents[event.startDate] = eventArray
        }
        
        return startTimeToEvents
    }
    
}


class EventStore {
    
    static var shared = EventStore()
    
    static func reloadYear(compleition: (() -> ())? = nil) {
        EKEventStore.store.requestAccess(to: .event) { (accepted, error) in
            if !accepted || error != nil {
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                shared.loadCourses()
                
                DispatchQueue.main.async {
                    if let compleition = compleition {
                        compleition()
                    }
                }
                
                
            }
        }
    }
    
    var namesToCourse = [String: Course]()
    var namesToCounts = [String: Int]()
    
    private init() { }
    
    private func loadCourses() {
        namesToCourse = [String: Course]()
        namesToCounts = [String: Int]()
        
        let year: TimeInterval = 3.15576E+07
        let today = Date()
        
        let predicate = EKEventStore.store.predicateForEvents(withStart: today.morning, end: today.addingTimeInterval(year), calendars: nil)
        let events = EKEventStore.store.events(matching: predicate)
        
        for event in events {
            let course = namesToCourse[event.title] ?? Course(event: event, color: Color.unselected)
            let event = Event(event: event, color: course.color)
            if !course.events.contains(event) {
                course.events.append(event)
            }
            namesToCourse[event.name] = course
            
            let newCount = (namesToCounts[event.name] ?? 0) + 1
            namesToCounts[event.name] = newCount
        }
    }
    
}
