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
    
    // MARK: Properties
    
    var session: WCSession?
    
    var transfer: [String: Data] {
        return ["periods": schoodule.storage.encoded]
    }
    
    let schoodule = Schoodule()
    
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

        createTable()
    }
    
    override func willActivate() {
        createTable()
        
        // only when table has changed
        if schoodule.hasPendingSend {
            sendUpdatedContents()
        }
    }
    
    override func awake(withContext context: Any?) {
        // grab from phone
        startSession()
        createTable()
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
            
            row.seperator?.setColor(period.color)
            row.indexLabel?.setTextColor(period.color)
            row.nameLabel?.setTextColor(period.color)
            
        }
        
    }
    
    func startSession() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    func sendUpdatedContents() {
        session?.sendMessage(["periods": schoodule.storage.encoded], replyHandler: { (period) in
            print("rec2")
        }) { (error) in
            print(error)
        }
    }
    
}

extension InterfaceController: WCSessionDelegate {
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        self.schoodule.storage.decodePeriods(from: applicationContext["periods"] as! Data)
        self.createTable()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        session.sendMessage(["message": "refreshRequest"], replyHandler: { (period) in
            print("rec1")
            self.schoodule.storage.decodePeriods(from: period["periods"] as! Data)
            self.createTable()
        }) { (error) in
            print(error)
        }
    }
    
}

