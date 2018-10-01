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
    
    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.name == rhs.name
    }
    
    lazy var events: [EKEvent] = {
        let year = 3.15576e7
        let predicate = EKEventStore().predicateForEvents(withStart: Date().addingTimeInterval(-year), end: Date().addingTimeInterval(year), calendars: nil)
        
        let foundEvents = EKEventStore().events(matching: predicate)
        return foundEvents.filter { $0.title == self.name }
    }()
    
    var event: EKEvent {
        return eventsForDate(date: Date())
    }
    
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
        let newEvent = EKEvent(eventStore: EKEventStore())
        
        newEvent.calendar = EKEventStore().defaultCalendarForNewEvents!
        newEvent.title = ""
        newEvent.startDate = Date().addingTimeInterval(-1000000)
        newEvent.endDate = Date().addingTimeInterval(-1000000)
        
        return newEvent
    }
    
}
