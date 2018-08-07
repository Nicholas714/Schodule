//
//  Period.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/29/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation
import UIKit

struct Course: Equatable, Comparable, Codable {
    
    private var uuid: UUID
    
    var name: String
    var gradient: Gradient
    var timeframe: Timeframe
    var location: String?
    var instructor: String?
    
    init(name: String, gradient: Gradient, timeframe: Timeframe, teacher: String? = nil, location: String? = nil) {
        self.name = name
        self.gradient = gradient
        self.timeframe = timeframe
        self.instructor = teacher
        self.location = location
        
        self.uuid = UUID()
    }
    
    static func ==(lhs: Course, rhs: Course) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    static func <(lhs: Course, rhs: Course) -> Bool {
        return lhs.timeframe.start < rhs.timeframe.start 
    }
    
}
