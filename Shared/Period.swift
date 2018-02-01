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

class Period: Equatable, Codable {
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        return dateFormatter
    }()
    
    let index: Int
    let className: String
    let start: Date
    let end: Date
    
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    
    var color: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    var startString: String {
        get {
            return dateFormatter.string(from: start)
        }
    }
    
    init(index: Int, className: String, color: UIColor, start: Date, end: Date) {
        self.index = index
        self.className = className
        self.start = start
        self.end = end
        
        let comp = color.cgColor.components!
        self.red = comp[0]
        self.green = comp[1]
        self.blue = comp[2]
    }
    
    static func ==(lhs: Period, rhs: Period) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end && lhs.className == rhs.className
    }
    
}
