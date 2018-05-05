//
//  Period.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/29/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation
import UIKit

struct Period: Equatable, Codable, Comparable, Hashable {
    
    var hashValue: Int
    
    var className: String
    var themeIndex: Int
    var timeframe: Timeframe
    var location: String?
    
    var color: UIColor {
        get {
            return Array(UIColor.themes.values)[themeIndex]
        }
    }
    
    init(className: String, themeIndex: Int, start: Time, end: Time) {
        self.className = className
        self.themeIndex = themeIndex
        self.timeframe = Timeframe(start: start, end: end)
        self.location = nil
        hashValue = className.hashValue + themeIndex.hashValue + start.hour.hashValue
    }
    
    static func ==(lhs: Period, rhs: Period) -> Bool {
        return lhs.timeframe.start == rhs.timeframe.start && lhs.timeframe.end == rhs.timeframe.end && lhs.className == rhs.className && lhs.themeIndex == rhs.themeIndex && lhs.location == rhs.location
    }
    
    static func <(lhs: Period, rhs: Period) -> Bool {
        return lhs.timeframe.start < rhs.timeframe.start
    }
    
}
