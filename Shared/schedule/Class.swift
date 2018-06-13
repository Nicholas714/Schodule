//
//  Period.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/29/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation
import UIKit

struct Class: Equatable, Comparable, Codable {
    
    var name: String
    var themeIndex: Int
    var timeframe: Timeframe
    var location: String?
    
    var color: UIColor {
        get {
            return Array(UIColor.themes.values)[themeIndex]
        }
    }
    
    static func ==(lhs: Class, rhs: Class) -> Bool {
        return lhs.timeframe == rhs.timeframe && lhs.name == rhs.name && lhs.themeIndex == rhs.themeIndex && lhs.location == rhs.location
    }
    
    static func <(lhs: Class, rhs: Class) -> Bool {
        return lhs.timeframe.start < rhs.timeframe.end
    }
    
}
