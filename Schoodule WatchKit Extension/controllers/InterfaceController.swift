//
//  InterfaceController.swift
//  Schoodule WatchKit Extension
//
//  Created by Nicholas Grana on 1/28/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {
  
    // MARK: Outlets
    
    @IBOutlet var createInfoLabel: WKInterfaceLabel!
    @IBOutlet var scheduleTable: WKInterfaceTable!
    @IBOutlet var newButton: WKInterfaceButton!
    
    // MARK: Properties
    
    var schoodule: Schoodule {
        return SchooduleManager.shared.schoodule
    }

    // MARK: WKInterfaceController functions
    
    override func willActivate() {
        if schoodule.unsortedPeriods.isEmpty {
            SchooduleManager.shared.loadScheudle()
        }
        createTable()
    }
    
    // MARK Segueing Data
    
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
     
    // MARK: UI/Table Population
    
    func createTable() {

        scheduleTable.setNumberOfRows(schoodule.unsortedPeriods.count, withRowType: "classRow")
        
        for (index, period) in schoodule.periods.enumerated() {
            loadRow(index: index, period: period)
        }
        
        reloadCurrent()
        showInfo()
    }
    
    func reloadCurrent() {
        let currentClass = schoodule.classFrom(date: Date())
        let nextClass = schoodule.nextClassFrom(date: Date())
        
        for (index, period) in schoodule.periods.enumerated() {
            let row = scheduleTable.rowController(at: index) as! ClassRow
            if period == currentClass || (period == nextClass && currentClass == nil) {
                row.group.setBackgroundColor(UIColor.white.withAlphaComponent(0.14))
            } else {
                row.group.setBackgroundColor(UIColor.clear)
            }
        }
    }
    
    func loadRow(index: Int, period: Period) {
        let row = scheduleTable.rowController(at: index) as! ClassRow
        
        row.durationLabel?.setText("\(period.timeframe.start.date.timeString)")
        row.indexLabel?.setText("\(index + 1)")
        row.nameLabel?.setText("\(period.className)")
        
        let color = period.color
        row.seperator?.setColor(color)
        row.indexLabel?.setTextColor(color)
        row.nameLabel?.setTextColor(color)
        row.durationLabel.setTextColor(UIColor.white)
        
        if let location = period.location {
            row.locationLabel.setText(location)
            row.locationLabel.setHidden(false)
        } else {
            row.locationLabel.setHidden(true)
        }
    }
    
    func showInfo() {
        if schoodule.unsortedPeriods.isEmpty {
            createInfoLabel.setHidden(false)
        } else {
            createInfoLabel.setHidden(true)
        }
        
        scheduleTable.setHidden(false)
        newButton.setHidden(false)
    }
    
}

extension Int {
    
    var indexSet: IndexSet {
        return IndexSet(integer: self)
    }
    
    
}
