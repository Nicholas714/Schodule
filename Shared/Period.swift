//
//  Period.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/29/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

typealias Hallway = Period

class Period {
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        return dateFormatter
    }()
    
    let className: String
    let start: Date
    let end: Date
    
    var startString: String {
        get {
            return dateFormatter.string(from: start)
        }
    }
    
    init(className: String, start: Date, end: Date) {
        self.className = className
        self.start = start
        self.end = end
    }
    
}
