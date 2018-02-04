//
//  Period.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/29/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation
import UIKit

typealias Hallway = Period

struct Period: Equatable, Codable, Comparable {
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        return dateFormatter
    }()
    
    var className: String
    var start: Date
    var end: Date
    
    var themeIndex: Int
    
    var color: UIColor {
        get {
            return Array(UIColor.themes.values)[themeIndex]
        }
    }
    
    var startString: String {
        mutating get {
            return self.dateFormatter.string(from: start)
        }
    }
    
    init(className: String, themeIndex: Int, start: Date, end: Date) {
        self.className = className
        self.themeIndex = themeIndex
        self.start = start
        self.end = end
    }
    
    func date(component: Calendar.Component, dateType type: DateType) -> Int {
        if component == .hour {
            return Calendar.current.component(component, from: (type == .start) ? start : end)
        }
        return Calendar.current.component(component, from: (type == .start) ? start : end)
    }
    
    func normalized() -> Period {
        let newStart = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: start), minute: Calendar.current.component(.minute, from: start), second: 0, of: Date())!
        let newEnd = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: end), minute:Calendar.current.component(.minute, from: end), second: 0, of: Date())!
        
        return Period(className: className, themeIndex: themeIndex, start: newStart, end: newEnd)
    }
    
    static func ==(lhs: Period, rhs: Period) -> Bool {
        let lhs = lhs.normalized()
        let rhs = rhs.normalized()
        return lhs.start == rhs.start && lhs.end == rhs.end && lhs.className == rhs.className
    }
    
    static func <(lhs: Period, rhs: Period) -> Bool {
        let lhs = lhs.normalized()
        let rhs = rhs.normalized()
        return lhs.start < rhs.start
    }
    
}

enum DateType {
    case start
    case end
}
