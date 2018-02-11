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
        let nextUpdate = Date().addingTimeInterval(7200)
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: nextUpdate, userInfo: nil) { (error) in }
    }
    
    func applicationDidEnterBackground() {
        manager.updateComplications()
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
                manager.updateComplications()
                
                // call in another 2 hours
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
        
        manager.sendRefreshRequest(replyHandler: { (period) in
            self.schoodule.storage.decodePeriods(from: period["periods"] as! Data)
        })
    }
    
}
