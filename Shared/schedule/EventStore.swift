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
        let year: TimeInterval = 3.15576E+07
        let todayStart = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        
        let predicate = EKEventStore.store.predicateForEvents(withStart: todayStart, end: todayStart.addingTimeInterval(year), calendars: nil)
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
