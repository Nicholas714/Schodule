//
//  BubbleEntry.swift
//  Schoodule
//
//  Created by Nicholas Grana on 10/3/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

class BubbleEntry: Equatable, Comparable {
    
    var course: Course
    var name: String
    var color: Color
    
    var sortPriority: Int {
        return course.events.count 
    }
    
    init(course: Course) {
        self.course = course
        self.name = course.name
        self.color = course.color
    }
    
    func populateCell(eventCell: CalendarEventCell) {
        eventCell.courseName.text = name
        eventCell.color = color
        
        eventCell.courseTeacher.text = nil 
        eventCell.courseLocation.text = nil
        eventCell.courseStartTime.text = nil
        eventCell.courseEndTime.text = nil
    }
    
    static func == (lhs: BubbleEntry, rhs: BubbleEntry) -> Bool {
        return lhs.course == rhs.course
    }
    
    static func < (lhs: BubbleEntry, rhs: BubbleEntry) -> Bool {
        return lhs.sortPriority > rhs.sortPriority
    }
    
}

class EventBubbleEntry: BubbleEntry {

    var location: String
    var startDate: Date
    var endDate: Date
    
    init(course: Course, event: Event) {
        self.location = event.location
        self.startDate = event.startDate
        self.endDate = event.endDate
        
        super.init(course: course)
    }
    
    override func populateCell(eventCell: CalendarEventCell) {
        super.populateCell(eventCell: eventCell)
        
        eventCell.courseLocation.text = location
        eventCell.courseStartTime.text = startDate.timeString
        eventCell.courseEndTime.text = endDate.timeString
    }
    
    
}
