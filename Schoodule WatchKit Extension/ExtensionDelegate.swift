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
    
    func createNextRefresh() {
        let nextUpdate = Date().addingTimeInterval(3600)
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: nextUpdate, userInfo: nil) { (error) in }
    }
    
    func applicationDidFinishLaunching() {
        manager.startSession(delegate: self)
        
        // start refresh cycle
        createNextRefresh()
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            // called to update timeline
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                SchooduleManager.shared.sendRefreshRequest(type: "complicationRefreshRequest", replyHandler: { (period) in
                }) { (error) in
                }
                
                createNextRefresh()
                
                backgroundTask.setTaskCompletedWithSnapshot(false)
            default:
                // called by system
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        self.schoodule.storage.decodePeriods(from: applicationContext["periods"] as! Data)
        
        DispatchQueue.main.async {
            self.root?.createTable()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if error != nil || activationState == .notActivated {
            print("error")
            (WKExtension.shared().rootInterfaceController as? InterfaceController)?.showError()
            return
        }
        
        manager.sendRefreshRequest(type: "refreshRequest", replyHandler: { (period) in
            self.schoodule.storage.decodePeriods(from: period["periods"] as! Data)
        })
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("recieved. decoding and updating complications...")
        self.schoodule.storage.decodePeriods(from: userInfo["periods"] as! Data)
        SchooduleManager.shared.updateComplications()
    }
    
}
