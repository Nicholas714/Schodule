//
//  Period.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/29/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import EventKit

// TODO: go through each event, and convert all events into CourseEvent which this will store as a list

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
    
    var color: Color
    var name: String
    
    init(name: String, color: Color? = nil) {
        self.name = name
        self.color = color ?? Color.randomBackground
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

struct Color: Codable {
    
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat
    
}

extension Color {
    
    static var backgrounds: [Color] {
        get {
            return [Color(red:0.21, green:0.21, blue:0.21, alpha:1.00),
                    Color(red:0.54, green:0.01, blue:0.04, alpha:1.00),
                    Color(red:0.87, green:0.31, blue:0.10, alpha:1.00),
                    Color(red:1.00, green:0.64, blue:0.00, alpha:1.00),
                    Color(red:0.19, green:0.67, blue:0.15, alpha:1.00),
                    Color(red:0.00, green:0.43, blue:0.73, alpha:1.00),
                    Color(red:0.18, green:0.13, blue:0.40, alpha:1.00),
                    Color(red:0.94, green:0.24, blue:0.43, alpha:1.00)]
        }
    }
    
    static var randomBackground: Color {
        return backgrounds.randomElement()!
    }
    
}

extension UIColor {
    
    convenience init(color: Color) {
        self.init(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
    }
    
}


