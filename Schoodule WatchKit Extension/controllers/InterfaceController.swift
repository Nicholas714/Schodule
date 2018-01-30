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
        createTable()
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        return schoodule.periods[rowIndex]
    }
 
    // MARK: Functions
    
    func createTable() {
        scheduleTable.setNumberOfRows(schoodule.periods.count, withRowType: "classRow")
        
        let generator = ColorGenerator()
        
        for (index, _) in schoodule.periods.enumerated() {
            let period = schoodule.periods[index]
            let row = scheduleTable.rowController(at: index) as! ClassRow            
            
            row.durationLabel?.setText("\(period.startString)")
            row.indexLabel?.setText("\(index + 1)")
            row.nameLabel?.setText("\(period.className)")
            
            row.seperator?.setColor(generator.currentColor)
            row.indexLabel?.setTextColor(generator.currentColor)
            row.nameLabel?.setTextColor(generator.currentColor)
            
            generator.nextColor()
            
        }
    }

}

