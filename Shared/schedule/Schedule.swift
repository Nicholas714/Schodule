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
            courses.sort()
        }
    }
    
    var todayCourses: [Course] {
        var todayCourses = [Course]()
        for course in courses {
            if course.eventsForDate(date: Date()).title != "" {
                todayCourses.append(course)
            }
        }
        return todayCourses
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
