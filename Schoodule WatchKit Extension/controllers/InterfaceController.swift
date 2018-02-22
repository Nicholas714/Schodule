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
import WatchConnectivity

class InterfaceController: WKInterfaceController {
  
    @IBOutlet var scheduleTable: WKInterfaceTable!
    
    @IBOutlet var connectingLabel: WKInterfaceLabel!
    @IBOutlet var newButton: WKInterfaceButton!
    @IBOutlet var retryButton: WKInterfaceButton!
    
    @IBAction func retrySessionConnect() {
        SchooduleManager.shared.startSession(delegate: WKExtension.shared().delegate as! ExtensionDelegate)
    }
    
    // MARK: Properties
    
    var schoodule: Schoodule {
        return SchooduleManager.shared.schoodule
    }
    
    var session: WCSession? {
        return SchooduleManager.shared.session
    }
    
    // last time the table was created, this stores it to detect when changes are made and only reloadTable when it is different
    var lastRefresh = [Period]()
    
    // if anything fails to send, the connection to the host iPhone is lost. disable UI.
    var errorHandler: ((Error) -> Void)? {
        return { (error) in
            self.showError()
        }
    }
    
    // stores if the table/info is displayed
    var isLoaded = false
        
    // MARK: WKInterfaceController functions
    
    override func willActivate() {
        // when table has changed, send contents
        if schoodule.hasPendingSend {
            SchooduleManager.shared.sendUpdatedContents(replyHandler: { (period) in
                self.schoodule.hasPendingSend = false
            }, errorHandler: errorHandler)
        }
        
        if schoodule.unsortedPeriods.isEmpty {
            SchooduleManager.shared.sendRefreshRequest(type: "refreshRequest", replyHandler: { (period) in
                self.schoodule.storage.decodePeriods(from: period["periods"] as! Data)
                
                self.createTable()
            }) { (error) in
                self.showError()
            }
        } else {
            self.createTable()
        }
        
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
     
    // MARK: Table Population
    
    func createTable() {
        
        if lastRefresh == schoodule.periods {
            print("same")
            return
        }
        
        print("different")
        
        scheduleTable.setNumberOfRows(schoodule.periods.count, withRowType: "classRow")
                
        for (index, period) in schoodule.periods.enumerated() {
            loadRow(index: index, period: period)
        }
        
        if let scroll = schoodule.pendingTableScrollIndex {
            scheduleTable.scrollToRow(at: scroll)
            schoodule.pendingTableScrollIndex = nil
        }

        showInfo()
        
        lastRefresh = schoodule.periods
    }
    
    func loadRow(index: Int, period: Period) {
        let currentClass = schoodule.classFrom(date: Date())
        let nextClass = schoodule.nextClassFrom(date: Date())
        
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
        } else {
            row.locationLabel.setHidden(true)
        }
        
        if period == currentClass || (period == nextClass && currentClass == nil) {
            row.group.setBackgroundColor(UIColor.white.withAlphaComponent(0.14))
        }
    }
    
    func showInfo() {
        if schoodule.periods.isEmpty {
            connectingLabel.setHidden(false)
            connectingLabel.setText("Tap to add a new class.")
        } else {
            connectingLabel.setHidden(true)
        }
        
        scheduleTable.setHidden(false)
        newButton.setHidden(false)
        retryButton.setHidden(true)

        if !isLoaded {
            DispatchQueue.main.async {
                self.addMenuItem(with: .trash, title: "Clear All", action: #selector(self.clearAllPeriods))
            }
        }
        
        isLoaded = true
    }
    
    func showError() {
        isLoaded = false
        connectingLabel.setText("Failed to connect.")
        connectingLabel.setHidden(false)
        retryButton.setHidden(false)
        newButton.setHidden(true)
        scheduleTable.setHidden(true)
    }
    
    // MARK: Actions
    
    @IBAction func updateComplications() {
        SchooduleManager.shared.updateComplications()
    }
    

    @objc func clearAllPeriods() {
        let clearAllConfirm = WKAlertAction(title: "Clear All", style: .destructive) {
            SchooduleManager.shared.sendClearRequest(replyHandler: { (period) in
                self.schoodule.storage.decodePeriods(from: period["periods"] as! Data)
                
                DispatchQueue.main.async {
                    self.createTable()
                }
            }, errorHandler: self.errorHandler)
        }
        
        self.presentAlert(withTitle: "Clear All Classes", message: "This action cannot be undone.", preferredStyle: .actionSheet, actions: [clearAllConfirm])
        
        
    }
    
}
