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

class Period: Equatable {
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        return dateFormatter
    }()
    
    let index: Int
    let className: String
    var color: UIColor
    let start: Date
    let end: Date
    
    var startString: String {
        get {
            return dateFormatter.string(from: start)
        }
    }
    
    init(index: Int, className: String, color: UIColor, start: Date, end: Date) {
        self.index = index
        self.className = className
        self.color = color
        self.start = start
        self.end = end
    }
    
    static func ==(lhs: Period, rhs: Period) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end && lhs.className == rhs.className
    }
    
}
