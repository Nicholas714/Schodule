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
        if let currentPeriod = schoodule.classFrom(date: Date()), let index = schoodule.index(of: currentPeriod) {
            scheduleTable.scrollToRow(at: index)
        } else if let nextPeriod = schoodule.nextClassFrom(date: Date()), let index = schoodule.index(of: nextPeriod) {
            scheduleTable.scrollToRow(at: index)
        }
    }
    
    override func willActivate() {
        createTable()
    }
    
    override func awake(withContext context: Any?) {
        schoodule.storage.loadScheudle()
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        if segueIdentifier == "editSegue" {
            return (schoodule, schoodule.periods[rowIndex])
        }
        return nil
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        if segueIdentifier == "createSegue" {
            return schoodule
        }
        return nil
    }
 
    // MARK: Functions
    
    func createTable() {
        scheduleTable.setNumberOfRows(schoodule.periods.count, withRowType: "classRow")
        
        for (index, _) in schoodule.periods.enumerated() {
            var period = schoodule.periods[index]
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

