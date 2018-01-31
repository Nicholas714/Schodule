//
//  InterfaceController.swift
//  Schoodule WatchKit Extension
//
//  Created by Nicholas Grana on 1/28/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import WatchKit
import ClockKit
import Foundation

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var scheduleTable: WKInterfaceTable!
    
    // MARK: Properties
    
    let schoodule = Schoodule()
    
    // MARK: WKInterfaceController functions
    
    override func didAppear() {
        if let currentPeriod = schoodule.classFrom(date: Date()) {
            scheduleTable.scrollToRow(at: currentPeriod.index)
            print(currentPeriod.index)
        } else if let nextPeriod = schoodule.nextClassFrom(date: Date()) {
            scheduleTable.scrollToRow(at: nextPeriod.index)
            print(nextPeriod.index)
        }
    }
    
    override func awake(withContext context: Any?) {
        createTable()
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        return schoodule.periods[rowIndex]
    }
 
    // MARK: Functions
    
    func createTable() {
        scheduleTable.setNumberOfRows(schoodule.periods.count, withRowType: "classRow")
        
        for (index, _) in schoodule.periods.enumerated() {
            let period = schoodule.periods[index]
            let row = scheduleTable.rowController(at: index) as! ClassRow            
            
            row.durationLabel?.setText("\(period.startString)")
            row.indexLabel?.setText("\(index + 1)")
            row.nameLabel?.setText("\(period.className)")
            
            row.seperator?.setColor(period.color)
            row.indexLabel?.setTextColor(period.color)
            row.nameLabel?.setTextColor(period.color)
            
        }
        
    }

}

