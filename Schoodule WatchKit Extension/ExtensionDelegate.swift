//
//  ExtensionDelegate.swift
//  Schoodule WatchKit Extension
//
//  Created by Nicholas Grana on 1/28/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    var manager = SchooduleManager.shared
    
    var schoodule: Schoodule {
        return manager.schoodule
    }
    
    var root: InterfaceController? {
        return WKExtension.shared().rootInterfaceController as? InterfaceController
    }
    
    func applicationDidFinishLaunching() {
        // try to start the session if it has not already been started
        manager.startSession(delegate: self)
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                
                if SchooduleManager.shared.schoodule.unsortedPeriods.isEmpty {
                    SchooduleManager.shared.loadScheudle()
                    
                    if SchooduleManager.shared.schoodule.unsortedPeriods.isEmpty {
                        manager.startSession(delegate: self)
                        SchooduleManager.shared.sendRefreshRequest(type: "refreshRequest", replyHandler: { (period) in
                            
                            if !self.schoodule.storage.decodePeriods(from: period["periods"] as! Data) {
                                SchooduleManager.shared.saveSchedule()
                                SchooduleManager.shared.updateComplications() 
                            }
                        })
                    }
                }
                
                if snapshotTask.reasonForSnapshot != .complicationUpdate {
                    print("STARTING SNAPSHOT TASK")

                    // when the app is sent to the background or scheduled (with setTaskCompletedWithSnapshot), update complications OTHERWISE try to update the UI with a new table
                    if snapshotTask.reasonForSnapshot == .appBackgrounded || snapshotTask.reasonForSnapshot == .appScheduled {
                        print("app was went to the background, update complications")
                        SchooduleManager.shared.updateComplications()
                    } else {
                        // this automatically refreshes the UI
                        manager.startSession(delegate: self)
                        root?.createTable()
                    }
                }
                
                // schedules a new snapshot update in 1 hour
                snapshotTask.setTaskCompletedWithSnapshot(true)
            default:
                // called by system
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    // MARK: WCSession
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        self.schoodule.storage.decodePeriods(from: applicationContext["periods"] as! Data)
        
        DispatchQueue.main.async {
            self.root?.createTable()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        manager.sendRefreshRequest(type: "refreshRequest", replyHandler: { (period) in
            self.schoodule.storage.decodePeriods(from: period["periods"] as! Data)
            
            SchooduleManager.shared.updateComplications()
        })
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("recieved. decoding and updating complications...")
        self.schoodule.storage.decodePeriods(from: userInfo["periods"] as! Data)
        SchooduleManager.shared.updateComplications()
        
        DispatchQueue.main.async {
            self.root?.createTable()
        }
    }
    
}
