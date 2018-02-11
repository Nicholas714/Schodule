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
        manager.startSession(delegate: WKExtension.shared().delegate as! ExtensionDelegate)
    }
    
    // MARK: Properties
    
    var manager = SchooduleManager.shared
    
    var schoodule: Schoodule {
        return manager.schoodule
    }
    
    var session: WCSession? {
        return manager.session
    }
    
    var transfer: [String: Data] {
        return ["periods": schoodule.storage.encoded]
    }
    
    // if anything fails to send, the connection to the host iPhone is lost. disable UI.
    var errorHandler: ((Error) -> Void)? {
        return { (error) in
            self.showError()
        }
    }
        
    // MARK: WKInterfaceController functions
    
    override func willActivate() {
        // when table has changed, send contents
        if schoodule.hasPendingSend {
            manager.sendUpdatedContents(replyHandler: { (period) in
                self.schoodule.hasPendingSend = false
            }, errorHandler: errorHandler)
        }
        
        if schoodule.unsortedPeriods.isEmpty {
            manager.sendRefreshRequest(replyHandler: { (period) in
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
 
    // MARK: Functions
    
    func createTable() {
        
        showInfo()
        
        scheduleTable.setNumberOfRows(schoodule.periods.count, withRowType: "classRow")
                
        for (index, period) in schoodule.periods.enumerated() {
            let row = scheduleTable.rowController(at: index) as! ClassRow            

            row.durationLabel?.setText("\(period.start.string)")
            row.indexLabel?.setText("\(index + 1)")
            row.nameLabel?.setText("\(period.className)")
            
            let color = Array(UIColor.themes.values)[index % 10]
            row.seperator?.setColor(color)
            row.indexLabel?.setTextColor(color)
            row.nameLabel?.setTextColor(color)
            row.durationLabel.setTextColor(UIColor.white)
        }

        var scrollIndex: Int?
        var highlightIndex: Int?
        
        if let currentPeriod = self.schoodule.classFrom(date: Date()), let index = self.schoodule.index(of: currentPeriod) {
            scrollIndex = index
            highlightIndex = index
        } else if let nextPeriod = self.schoodule.nextClassFrom(date: Date()), let index = self.schoodule.index(of: nextPeriod) {
            scrollIndex = index
            highlightIndex = index
        }
        
        if let index = schoodule.pendingTableScrollIndex {
            scrollIndex = index
            schoodule.pendingTableScrollIndex = nil
        }
        
        if let scroll = scrollIndex {
            scheduleTable.scrollToRow(at: scroll)
        }
        
        if let highlight = highlightIndex {
            let row = scheduleTable.rowController(at: highlight) as! ClassRow
            row.group.setBackgroundColor(UIColor.white.withAlphaComponent(0.18))
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
    }
    
    func showError() {
        connectingLabel.setText("Failed to connect.")
        connectingLabel.setHidden(false)
        retryButton.setHidden(false)
        newButton.setHidden(true)
        scheduleTable.setHidden(true)
    }
    
    @IBAction func clearAllPeriods() {
        manager.sendClearRequest(replyHandler: { (period) in
            self.schoodule.storage.decodePeriods(from: period["periods"] as! Data)
            
            DispatchQueue.main.async {
                self.createTable()
            }
        }, errorHandler: errorHandler)
    }
    
}
