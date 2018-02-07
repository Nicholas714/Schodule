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
        (WKExtension.shared().delegate as? ExtensionDelegate)?.startSession()
    }
    // MARK: Properties
    
    var session: WCSession? {
        return (WKExtension.shared().delegate as? ExtensionDelegate)?.session
    }
    
    var transfer: [String: Data] {
        return ["periods": schoodule.storage.encoded]
    }
    
    var schoodule: Schoodule {
        return (WKExtension.shared().delegate as! ExtensionDelegate).schoodule
    }
        
    // MARK: WKInterfaceController functions
    
    override func didAppear() {
        if let index = schoodule.pendingTableScrollIndex {
            scheduleTable.scrollToRow(at: index)
            schoodule.pendingTableScrollIndex = nil
            return
        }
    }
    
    override func willActivate() {
        // only when table has changed
        if schoodule.hasPendingSend {
            sendUpdatedContents()
            createTable()
        }
        
        let currentPeriod = schoodule.classFrom(date: Date())
        for (index, period) in schoodule.periods.enumerated() {
            let row = scheduleTable.rowController(at: index) as! ClassRow
            
            if currentPeriod == period {
                row.group.setBackgroundColor(UIColor.white.withAlphaComponent(0.18))
            }
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
            
        }

        if let currentPeriod = self.schoodule.classFrom(date: Date()), let index = self.schoodule.index(of: currentPeriod) {
            self.scheduleTable.scrollToRow(at: index)
        } else if let nextPeriod = self.schoodule.nextClassFrom(date: Date()), let index = self.schoodule.index(of: nextPeriod) {
            self.scheduleTable.scrollToRow(at: index)
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
    }
    
    func showError() {
        connectingLabel.setText("Failed to connect.")
        retryButton.setHidden(false)
        newButton.setHidden(true)
        scheduleTable.setHidden(true)
    }
    
    func sendUpdatedContents() {
        session?.sendMessage(["periods": schoodule.storage.encoded], replyHandler: { (period) in
            self.schoodule.hasPendingSend = false
        }) { (error) in
            self.showError()
            print(error)
        }
    }
    
}

