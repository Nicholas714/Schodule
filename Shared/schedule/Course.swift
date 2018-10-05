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

class Course: Codable, Equatable {
    
    var todayEvents: [Event] {
        return eventsForDate(date: Date())
    }
    
    var name: String
    var color: Color {
        didSet {
            for i in 0..<events.count {
                var newEvent = events[i]
                newEvent.color = color
                events[i] = newEvent
            }
        }
    }
    var events = [Event]()
    
    init(event: EKEvent, color: Color) {
        self.name = event.title
        self.color = color 
    }
    
    func eventsForDate(date: Date) -> [Event] {
        var dateEvents = [Event]()
        
        for event in events {
            if date.dayString == event.startDate.dayString {
                dateEvents.append(event)
            }
        }
        
        return dateEvents
    }
    
    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.name == rhs.name 
    }
    
}

struct Event: Codable, Equatable, Comparable, Hashable {
    
    var hashValue: Int {
        return name.hashValue
    }
    
    var name: String
    var color: Color
    let location: String
    let startDate: Date
    let endDate: Date
    
    init(event: EKEvent, color: Color) {
        self.name = event.title 
        self.color = color
        self.location = event.location ?? ""
        self.startDate = event.startDate
        self.endDate = event.endDate
    }
    
    static func < (lhs: Event, rhs: Event) -> Bool {
        return lhs.startDate < rhs.startDate
    }
    
}

struct Color: Codable, Equatable {
    
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat
    
}

extension Color {
    
    static var unselected = Color(red: 119/255.0, green: 119/255.0, blue: 119/255.0, alpha: 1.0)
    
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


