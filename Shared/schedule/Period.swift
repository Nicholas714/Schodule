//
//  Period.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/29/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation
import UIKit

struct Period: Equatable, Codable, Comparable {
    
    var className: String
    var themeIndex: Int
    var timeframe: Timeframe
    var location: String?
    
    var color: UIColor {
        get {
            return Array(UIColor.themes.values)[themeIndex]
        }
    }
    
    static func ==(lhs: Period, rhs: Period) -> Bool {
        return lhs.timeframe == rhs.timeframe && lhs.className == rhs.className && lhs.themeIndex == rhs.themeIndex && lhs.location == rhs.location
    }
    
    static func <(lhs: Period, rhs: Period) -> Bool {
        return lhs.timeframe.start! < rhs.timeframe.end!
    }
    
}
