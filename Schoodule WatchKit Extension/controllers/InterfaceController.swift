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
    
    @IBOutlet var scheduleTable: WKInterfaceTable!
    @IBOutlet var connectingLabel: WKInterfaceLabel!
    @IBOutlet var newButton: WKInterfaceButton!
    
    // MARK: Properties
    
    var schoodule: Schoodule {
        return SchooduleManager.shared.schoodule
    }
    
    var session: WCSession? {
        return SchooduleManager.shared.session
    }

    // MARK: WKInterfaceController functions
    
    override func willActivate() {
        // when table has changed, send contents
        if schoodule.hasPendingSend {
            SchooduleManager.shared.sendUpdatedContents(replyHandler: { (period) in
                self.schoodule.hasPendingSend = false
            }, errorHandler: nil)
        }
        
        if schoodule.unsortedPeriods.isEmpty {
            SchooduleManager.shared.loadScheudle()
            createTable()
            
            // try to fetch new list from iPhone if it is reachable
            SchooduleManager.shared.sendRefreshRequest(type: "refreshRequest", replyHandler: { (period) in
                
                if !self.schoodule.storage.decodePeriods(from: period["periods"] as! Data) {
                    SchooduleManager.shared.saveSchedule()
                    self.createTable()
                }
            })
        } else {
            createTable()
        }
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
        pendingScroll()
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
        
        row.durationLabel?.setText("\(period.start.string)")
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
    
    func pendingScroll() {
        if let scroll = schoodule.pendingTableScrollIndex {
            scheduleTable.scrollToRow(at: scroll)
            schoodule.pendingTableScrollIndex = nil
        }
    }
    
    func showInfo() {
        if schoodule.unsortedPeriods.isEmpty {
            connectingLabel.setHidden(false)
        } else {
            connectingLabel.setHidden(true)
        }
        
        scheduleTable.setHidden(false)
        newButton.setHidden(false)
    }
    
    // MARK: Actions
    
    @IBAction func clearAllPeriods() {
        let clearAllConfirm = WKAlertAction(title: "Clear All", style: .destructive) {
            self.schoodule.clear()
            
            DispatchQueue.main.async {
                self.createTable()
            }
            
            SchooduleManager.shared.sendClearRequest(replyHandler: { (period) in
                
            }, errorHandler: nil)
        }
        
        self.presentAlert(withTitle: "Clear All Classes", message: "This action cannot be undone.", preferredStyle: .actionSheet, actions: [clearAllConfirm])
    }
    
}

extension Int {
    
    var indexSet: IndexSet {
        return IndexSet(integer: self)
    }
    
    
}
