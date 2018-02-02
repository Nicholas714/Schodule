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

struct Period: Equatable, Codable {
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        return dateFormatter
    }()
    
    var index: Int
    var className: String
    var start: Date
    var end: Date
    
    var red: CGFloat!
    var green: CGFloat!
    var blue: CGFloat!
    
    var color: UIColor {
        get {
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
        set {
            let comp = newValue.cgColor.components!
            self.red = comp[0]
            self.green = comp[1]
            self.blue = comp[2]
        }
    }
    
    var startString: String {
        mutating get {
            return self.dateFormatter.string(from: start)
        }
    }
    
    init(index: Int, className: String, color: UIColor, start: Date, end: Date) {
        self.index = index
        self.className = className
        self.start = start
        self.end = end
        self.color = color
    }
    
    init() {
        self.init(index: -1, className: "Class", color: UIColor(red: 1, green: 1, blue: 1, alpha: 1.0), start: Date(), end: Date()) 
    }
    
    static func ==(lhs: Period, rhs: Period) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end && lhs.className == rhs.className
    }
    
}
