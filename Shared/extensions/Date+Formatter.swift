//
//  Date+Formatter.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

extension Date {
    
    var timeFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter
    }
    
    var timeString: String {
        return timeFormatter.string(from: self)
    }
    
    var dayFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        return dateFormatter
    }
    
    var dayString: String {
        return dayFormatter.string(from: self)
    }
    
    func areComponenetsEqual(componenets: [Calendar.Component], with date: Date) -> Bool {
        for componenet in componenets {
            if Calendar.current.component(componenet, from: self) != Calendar.current.component(componenet, from: date) {
                return false
            }
        }
        return true 
    }
    
}
