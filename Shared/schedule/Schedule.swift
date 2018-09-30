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
    
    var courses = [Course]() {
        didSet {
            
            courses = courses.filter { EKEventStore().event(withIdentifier: $0.eventIdentifier) != nil }
            
            print("classList set")
            courses.sort()
        }
    }
    
    var todayCourses: [Course] { 
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now)!
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now)!
        let predicate = EKEventStore().predicateForEvents(withStart: start, end: end, calendars: nil)
        print(courses)
        return EKEventStore().events(matching: predicate).map { Course(eventIdentifier: $0.eventIdentifier) }.filter { courses.contains($0) }
    }
    
    func classFrom(date: Date) -> Course? {
        return todayCourses.first { (course) -> Bool in
            return date <= course.event.endDate && date >= course.event.startDate
        }
    }
    
    func nextClassFrom(date: Date) -> Course? {
        return todayCourses.first { (course) -> Bool in
            return date < course.event.startDate
        }
    }
    
}
