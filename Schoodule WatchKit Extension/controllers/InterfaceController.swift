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

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    var session: WCSession!
    
    @IBAction func sendData() {
        session.sendMessageData(schoodule.storage.encodePeriods()!, replyHandler: { (data) in
            
        }) { (error) in
            
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        schoodule.storage.decodePeriods(from: messageData)
        print("recieved")
        createTable()
    }
    
    @IBOutlet var scheduleTable: WKInterfaceTable!
    
    // MARK: Properties
    
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
        if WCSession.isSupported() {
            session = WCSession.default
            session.delegate = self
            session.activate()
            print("activated.")
        }
        
        createTable()
    }
    
    override func awake(withContext context: Any?) {
        // grab from phone
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
    
}

