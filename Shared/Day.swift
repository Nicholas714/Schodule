//
//  Day.swift
//  Schoodule
//
//  Created by Nicholas Grana on 2/11/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

struct Day: Equatable, Codable {

    static let weekdays = [monday, tuesday, wednesday, thursday, friday]
    static let days = [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
    
    static let sunday = Day(name: "Sunday")
    static let monday = Day(name: "Monday")
    static let tuesday = Day(name: "Tuesday")
    static let wednesday = Day(name: "Wednesday")
    static let thursday = Day(name: "Thursday")
    static let friday = Day(name: "Friday")
    static let saturday = Day(name: "Saturday")
    
    let name: String

    var shortName: String {
        return String(name.prefix(3))
    }
    
    var index: Int {
        return Day.days.index(of: self)!
    }
    
}
