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
        
        if let currentPeriod = schoodule.classFrom(date: Date()), let index = schoodule.index(of: currentPeriod) {
            scheduleTable.scrollToRow(at: index)
        } else if let nextPeriod = schoodule.nextClassFrom(date: Date()), let index = schoodule.index(of: nextPeriod) {
            scheduleTable.scrollToRow(at: index)
        }
        
    }
    
    override func willActivate() {
        // only when table has changed
        if schoodule.hasPendingSend {
            sendUpdatedContents()
            createTable()
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
        scheduleTable.setNumberOfRows(schoodule.periods.count, withRowType: "classRow")
        
        for (index, var period) in schoodule.periods.enumerated() {
            let row = scheduleTable.rowController(at: index) as! ClassRow            

            row.durationLabel?.setText("\(period.startString)")
            row.indexLabel?.setText("\(index + 1)")
            row.nameLabel?.setText("\(period.className)")
            
            let color = Array(UIColor.themes.values)[index]
            row.seperator?.setColor(color)
            row.indexLabel?.setTextColor(color)
            row.nameLabel?.setTextColor(color)
            
            print("\(index) - \(color.cgColor.components!.description)")
        }
        
    }
    
    func sendUpdatedContents() {
        session?.sendMessage(["periods": schoodule.storage.encoded], replyHandler: { (period) in
            self.schoodule.hasPendingSend = false
            print("rec2")
        }) { (error) in
            print(error)
        }
    }
    
}

