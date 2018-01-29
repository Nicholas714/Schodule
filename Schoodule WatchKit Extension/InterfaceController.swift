//
//  InterfaceController.swift
//  Schoodule WatchKit Extension
//
//  Created by Nicholas Grana on 1/28/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
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
    
    let names = ["Economics", "Electronics", "Statistics", "Lunch", "Calculus", "Comp Sci", "Literature", "Gym", "Physics"]
    
    @IBOutlet var scheduleTable: WKInterfaceTable!
    
    override func didAppear() {
        scheduleTable.setNumberOfRows(names.count, withRowType: "classRow")
    
        let generator = ColorGenerator()
        
        for (index, name) in names.enumerated() {
            let row = scheduleTable.rowController(at: index) as! ClassRow
            
            row.durationLabel?.setText("40 min")
            row.indexLabel?.setText("\(index + 1)")
            row.nameLabel?.setText("\(name)")
            row.seperator?.setColor(generator.currentColor)
            
            generator.nextColor()
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        // let row = table.rowController(at: rowIndex) as! ClassRow
        
        self.presentController(withName: "Class Edit", context: names[rowIndex])
    }
    
}

