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
    
    var eventIdentifier: String
    
    lazy var event: EKEvent = {
        return EKEventStore().event(withIdentifier: self.eventIdentifier)!
    }()
    
    var name: String {
        return event.title 
    }
    
    init(eventIdentifier: String) {
        self.eventIdentifier = eventIdentifier
    }
    
    static func ==(lhs: Course, rhs: Course) -> Bool {
        return lhs.eventIdentifier == rhs.eventIdentifier
    }
    
    static func <(lhs: Course, rhs: Course) -> Bool {
        return lhs.event.startDate < rhs.event.startDate
    }
    
}
