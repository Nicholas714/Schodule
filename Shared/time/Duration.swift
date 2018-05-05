//
//  File.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

struct Timeframe: Codable {
    
    var start: Time
    var end: Time
    
    func isInTimeframe(_ date: Date) -> Bool {
        return date <= start.date && date >= end.date
    }
    
}

struct Dateframe: Codable {
    
    var start: Date
    var end: Date
    
    func isInTimeframe(_ date: Date) -> Bool {
        return date <= start && date >= end
    }
    
}
