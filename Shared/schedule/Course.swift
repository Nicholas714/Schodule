//
//  Period.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/29/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import EventKit

class Course: Equatable, Comparable, Codable {
    
    static var eventStore = EKEventStore()
    
    static var events: [EKEvent]!
    
    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.name == rhs.name
    }
    
    lazy var events: [EKEvent] = {
        if Course.events == nil {
            let year: TimeInterval = 3.15576e7
            let predicate = Course.eventStore.predicateForEvents(withStart: Date().addingTimeInterval(-year), end: Date().addingTimeInterval(year), calendars: nil)
            print("looking...")
            Course.events = Course.eventStore.events(matching: predicate)
        }
        
        return Course.events.filter { $0.title == self.name }
    }()
    
    lazy var event: EKEvent = {
        return eventsForDate(date: Date())
    }()
    
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func eventsForDate(date: Date) -> EKEvent {
        for event in events {
            if event.startDate.dayString == date.dayString {
                return event
            }
        }
        return blankEvent()
    }
    
    static func <(lhs: Course, rhs: Course) -> Bool {
        return lhs.event.startDate < rhs.event.startDate
    }
    
    func blankEvent() -> EKEvent {
        let newEvent = EKEvent(eventStore: Course.eventStore)
        
        newEvent.calendar = Course.eventStore.defaultCalendarForNewEvents!
        newEvent.title = ""
        newEvent.startDate = Date().addingTimeInterval(-1000000)
        newEvent.endDate = Date().addingTimeInterval(-1000000)
        
        return newEvent
    }
    
}


