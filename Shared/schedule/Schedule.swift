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
        return lhs.courses == rhs.courses
    }
    
    var courses = [Course]()
    
    var todayEvents: [Event] {
        return courses.flatMap { $0.events }.sorted()
    }
    
    func eventFrom(date: Date) -> Event? {
        return todayEvents.first { (event) -> Bool in
            return date <= event.endDate && date >= event.startDate
        }
    }
    
    func nextClassFrom(date: Date) -> Event? {
        return todayEvents.first { (event) -> Bool in
            return date < event.startDate
        }
    }
    
}
