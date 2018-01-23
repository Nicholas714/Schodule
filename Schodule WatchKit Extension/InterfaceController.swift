//
//  InterfaceController.swift
//  Schodule WatchKit Extension
//
//  Created by Nicholas Grana on 9/13/17.
//  Copyright © 2017 Nicholas Grana. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    var morningStart: Date {
        get {
            let calender = Calendar.current
            return calender.date(bySettingHour: 7, minute: 05, second: 0, of: Date())!
        }
    }
    
    let names = ["Intro to Criminology", "Electronics 1", "AP Statistics", "Lunch", "AP Calculus", "AP Comp Science", "AP Literature", "Physical Education", "AP Physics"]
    
    @IBOutlet var scheduleTable: WKInterfaceTable!
    
    override func didAppear() {
        scheduleTable.setNumberOfRows(names.count, withRowType: "mainRowType")
        for (index, name) in names.enumerated() {
                let row = scheduleTable.rowController(at: index) as! MainRowType
                let label = row.rowDescription
                label?.setText("\(name)")
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        // TODO: open information for period
    }
    
}
