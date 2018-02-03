//
//  Date+Edit.swift
//  Schoodule WatchKit Extension
//
//  Created by Nicholas Grana on 2/2/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

extension Calendar {
    
    func replace(componenet: Calendar.Component, with newValue: Int, for date: Date) -> Date {
        if componenet == .hour {
            if newValue >= 23 {
                return Calendar.current.date(bySettingHour: 0, minute: Calendar.current.component(.minute, from: date), second: 0, of: date)!
            }
            return Calendar.current.date(bySettingHour: newValue, minute: Calendar.current.component(.minute, from: date), second: 0, of: date)!
        } else {
            return Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: date), minute: newValue, second: 0, of: date)!
        }
    }
    
}
